import uuid
from datetime import datetime
from decimal import Decimal
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field

Category = Literal["shirt", "t-shirt", "pants", "jacket"]
ConditionGrade = Literal["A", "B", "C", "D"]


class ProductCreate(BaseModel):
    title: str = Field(min_length=2, max_length=120)
    description: str | None = None
    category: Category
    price: Decimal = Field(gt=0, max_digits=12, decimal_places=2)
    latitude: float = Field(ge=-90, le=90)
    longitude: float = Field(ge=-180, le=180)
    image_url: str | None = None


class ProductRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    seller_id: uuid.UUID
    title: str
    description: str | None
    category: str
    price: Decimal
    condition_grade: str | None
    image_url: str | None
    status: str
    created_at: datetime
