# Thrifty

Thrifty is a Flutter marketplace for nearby secondhand clothing. The project includes a Riverpod-ready Android app, a FastAPI backend, and PostgreSQL with PostGIS for radius-based product discovery. The backend and database run directly on Windows; Docker is not required.

## Prerequisites

- Flutter and Dart (Flutter 3.47 or newer)
- PostgreSQL for Windows and its matching PostGIS bundle
- Android Studio or an Android device/emulator for Android development
- `uv` for managing the backend's Python environment

## Install PostgreSQL and PostGIS on Windows

1. Install PostgreSQL using the [official Windows installer](https://www.postgresql.org/download/windows/). Keep the default port `5432` and include pgAdmin and StackBuilder.
2. Open StackBuilder, select the PostgreSQL server you installed, then choose the latest compatible PostGIS bundle under **Spatial Extensions**. PostGIS Windows bundles are provided for supported PostgreSQL versions; install a bundle matching your PostgreSQL major version ([PostGIS Windows installation guide](https://postgis.net/documentation/getting_started/install_windows/), [released versions](https://postgis.net/documentation/getting_started/install_windows/released_versions/)).
3. Open pgAdmin and connect to the local server as `postgres`. In the Query Tool, create the local app role and database:

   ```sql
   CREATE ROLE thrifty LOGIN PASSWORD 'thrifty_local';
   CREATE DATABASE thrifty OWNER thrifty;
   ```

4. Connect pgAdmin to the new `thrifty` database as `postgres`, open its Query Tool, and enable PostGIS:

   ```sql
   CREATE EXTENSION postgis;
   SELECT PostGIS_Full_Version();
   ```

The migration also checks for the PostGIS extension, but enabling it once as the local PostgreSQL administrator avoids permission problems when migrations run as the restricted `thrifty` app role.

## Start the backend

If `uv` is not installed, install it from the official [uv installation guide](https://docs.astral.sh/uv/getting-started/installation/); on Windows, `winget install --id=astral-sh.uv -e` is one option.

From the repository root, create the backend environment file, then open a terminal in `backend/`:

```powershell
Copy-Item backend/.env.example backend/.env
Set-Location backend
uv sync
uv run alembic upgrade head
uv run fastapi dev app/main.py --host 0.0.0.0
```

The example connects to `localhost:5432` with the local-only `thrifty` role above. If you chose a different password or port, edit `backend/.env` first. Keep the API terminal open while using the app.

The API is at `http://localhost:8000`; interactive API docs are at `http://localhost:8000/docs`. `GET /api/v1/health` checks the API process and `GET /api/v1/health/ready` checks the database connection.

## Run the Flutter app

Open a second terminal at the repository root:

```powershell
flutter pub get
flutter run
```

For an Android emulator, the default API URL is `http://10.0.2.2:8000/api/v1`. For a physical Android device, pass your development computer's LAN IP address and keep both devices on the same trusted network:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api/v1
```

Replace `10.0.2.2` with your computer's LAN IP when using a physical phone. The Android debug build allows local HTTP for development; use HTTPS for deployed environments.

## Flutter structure

- `lib/app.dart` — Material 3 themes and GoRouter navigation
- `lib/data/api_client.dart` — shared Dio configuration and API base URL
- `lib/data/models/` — API data models
- `lib/data/repositories/` — API access behind repository methods
- `lib/providers/` — Riverpod state, filters, and async data providers
- `lib/pages/` — screens that render provider loading, error, empty, and data states
- `assets/brand/` — Thrifty brand mark source artwork
- `backend/app/` — FastAPI routes, settings, database session, schemas, and models
- `backend/migrations/` — Alembic database migrations

Riverpod is provided through a root `ProviderScope`. The nearby marketplace requests products from the backend through the repository and Dio client. The initial location is Malang city center; device GPS integration is not part of this setup. An empty state is expected until nearby products exist in the database. Authentication, listing management, image storage, and the trained condition-grading model still need to be implemented as product features.
