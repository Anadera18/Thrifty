from typing import Annotated

from fastapi import APIRouter, Depends, Query
from geoalchemy2 import Geography
from sqlalchemy import bindparam, cast, func, select, text
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import Product
from app.schemas import Category, ProductRead

router = APIRouter()
Database = Annotated[Session, Depends(get_db)]


@router.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@router.get("/health/ready")
def readiness(db: Database) -> dict[str, str]:
    db.execute(text("SELECT 1"))
    return {"status": "ready"}


@router.get("/products/nearby", response_model=list[ProductRead])
def nearby_products(
    db: Database,
    latitude: Annotated[float, Query(ge=-90, le=90)],
    longitude: Annotated[float, Query(ge=-180, le=180)],
    radius_km: Annotated[float, Query(gt=0, le=200)] = 10,
    category: Category | None = None,
    limit: Annotated[int, Query(ge=1, le=100)] = 30,
) -> list[Product]:
    origin = cast(
        func.ST_SetSRID(
            func.ST_MakePoint(
                bindparam("longitude", longitude),
                bindparam("latitude", latitude),
            ),
            4326,
        ),
        Geography(geometry_type="POINT", srid=4326),
    )
    statement = (
        select(Product)
        .where(
            Product.status == "available",
            func.ST_DWithin(
                Product.location,
                origin,
                bindparam("radius_meters", radius_km * 1000),
            ),
        )
        .order_by(func.ST_Distance(Product.location, origin))
        .limit(limit)
    )
    if category is not None:
        statement = statement.where(Product.category == category)
    return list(db.scalars(statement).all())
