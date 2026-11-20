# THRIFTY maps and location

This document explains how the map and location features work, which packages
they use, the policies they must respect, and the limits of the current
prototype. It contains no keys.

## 1. What the app does with location

- **Sellers** place a pickup pin on an OpenStreetMap map when creating a
  listing. The chosen coordinates are saved with the product.
- **Buyers** see a pickup map on the product detail screen, and can filter and
  sort listings by their real distance from the buyer's position.
- **Distances** are computed on the device. The buyer's position is **never**
  sent to any server, and is kept **in memory only** for the session.

### Privacy decisions

- Coordinates are rounded to **3 decimals (~110 m)** before they are saved, so
  buyers see an approximate pickup area, not an exact doorstep.
- The buyer's position is never stored on the backend and never uploaded.
- The buyer's position is not persisted between launches; it is re-detected (or
  re-entered) each session.
- Location is requested **only while the app is in use**. There is no
  background or continuous tracking.

## 2. Packages

| Package | Version | Purpose |
|---|---|---|
| `flutter_map` | 8.3.2 | Rendering OpenStreetMap raster tiles |
| `latlong2` | 0.10.1 | `LatLng` coordinate type |
| `geolocator` | 14.1.1 | Device position and `distanceBetween` |

`flutter_map` 8.2.0+ includes built-in (in-memory) tile caching in its
`NetworkTileProvider`, which satisfies the OSM "cache tiles" requirement while
the app is running. On the web, the browser HTTP cache additionally persists
tiles between visits.

## 3. One tile URL constant

Every map surface imports its constants from a **single file**:

`frontend/lib/shared/config/map_config.dart`

```dart
static const String osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
static const String osmAttribution = '© OpenStreetMap contributors';
static const String userAgentPackageName = 'com.thrifty.thrifty';
```

To switch to another tile provider (for example a paid service or a
self-hosted server before a real launch), change `osmTileUrl` (and, if needed,
the attribution) **in this one file**. No code search is required.

The reusable map widget is `frontend/lib/shared/widgets/osm_map_view.dart`.
It always draws the tile layer, a pin, and a visible attribution, and shows a
"Location not available" placeholder when there is no point to show.

## 4. Reusable pieces

| File | Responsibility |
|---|---|
| `shared/config/map_config.dart` | All map/tile/geocoding constants |
| `shared/widgets/osm_map_view.dart` | Read-only map card with attribution and placeholder |
| `shared/widgets/map_clusterer.dart` | Dependency-free screen-space marker clustering |
| `shared/widgets/osm_location_picker_sheet.dart` | Seller/buyer location picker (tap or search) |
| `core/services/location_service.dart` | Position, permission handling, distance, geocoding (cached, throttled) |
| `core/state/user_location_provider.dart` | The single shared buyer location (Riverpod `Notifier`) |

## 5. OpenStreetMap policies (current at 2026-11-20)

### Tile server (`operations.osmfoundation.org/policies/tiles/`)

- The public server is **donated infrastructure** and is **not** for heavy
  traffic. It has no SLA and access can be withdrawn.
- Use the exact HTTPS URL `https://tile.openstreetmap.org/{z}/{x}/{y}.png`.
- A **visible attribution** ("© OpenStreetMap contributors") is required and
  must not be hidden.
- A **valid, identifying User-Agent** is required on native platforms; the
  library default or a generic value may be blocked. Browsers send their own
  User-Agent on the web.
- **Caching** is required (honour server headers, or at least 7 days).
- **Bulk downloading / offline prefetching is forbidden.** The app never
  prefetches tiles.

### Nominatim geocoding (`operations.osmfoundation.org/policies/nominatim/`)

- Maximum **1 request per second**.
- A valid identifying **User-Agent or Referer** is required (stock library
  agents are refused).
- Clear **attribution** is required.
- Results **must be cached**.
- **Autocomplete is forbidden.** In the app, search runs only when the user
  presses the Search action, never while typing.

Both services are called only from `LocationService`, which enforces the
throttle and the cache.

## 6. What a real launch would need

The current setup is a **prototype**:

- Publishing to real users requires a **different tile provider** (self-hosted
  or a commercial/self-hosted OSM-derived service), because the public OSM tile
  server is not permitted for a production app with meaningful traffic.
- Address search would likewise need a self-hosted or commercial geocoding
  service.
- These are configuration changes in `map_config.dart`, plus raising any tile
  limits with the chosen provider.

## 7. Marker clustering

The nearby map groups pins that would overlap into a numbered bubble.

- Implementation: `shared/widgets/map_clusterer.dart`. It is **hand-rolled**
  and adds **no dependency**. `flutter_map_marker_cluster` was evaluated but
  rejected: it pins `latlong2 ^0.9.1`, which conflicts with this project's
  `latlong2 0.10.1` and would have forced a downgrade.
- How it works: each product is projected with the map's own
  `MapCamera.latLngToScreenOffset`. Points within 48 screen pixels are grouped;
  the group is drawn as a circle showing the count, otherwise as a normal price
  pin.
- **Zoom out** merges pins; **zoom in** splits them; **tapping a bubble** opens
  a list of the listings inside it.
- Because clustering follows the camera, the map recomputes groups on every pan
  and zoom.
- **Tapping a cluster bubble** opens a bottom sheet listing every product in the
  group, so each one is always reachable even when two listings share nearly the
  same coordinates and zooming could never separate them. The sheet also has a
  "Zoom in" action. The buyer's own position dot is drawn *below* the product
  markers so a bubble is never hidden or blocked by it.

## 8. Known limitations

- Coordinates are approximate (3 decimals / ~110 m); this is intentional.
- Products saved without coordinates show no distance and are excluded from
  radius-filtered results.
- The buyer's location is not remembered between launches.
- Password reset and other non-map features are out of scope of this document.
- On the web, `userAgentPackageName` is ignored; the browser's own User-Agent
  and Referer are used instead.

## 9. Tests

Run from `frontend`:

```powershell
flutter analyze
flutter test
```

`test/location_service_test.dart` covers distance and formatting against two
known city pairs, the 3-decimal rounding, and coordinate range validation.
`test/user_location_provider_test.dart` covers the shared location state.
`test/map_clusterer_test.dart` covers clustering: merging, splitting on zoom,
radius sensitivity, and the empty case.

## 10. Manual acceptance test table (SQA)

Use disposable test accounts and listings. Distances should be plausible for
the chosen places. "Chrome" below means any Chromium-based browser on
`http://localhost`; Android is a real device or emulator.

| ID | Steps | Expected result | Chrome | Android |
|---|---|---|---|---|
| MAP-01 | Open a listing that has coordinates from Home. | Product Detail shows a map card, tiles render, a red pin sits at the pickup point. | Yes | Yes |
| MAP-02 | Look at the map card's bottom-right corner and open the attribution. | "© OpenStreetMap contributors" is clearly visible and not hidden. | Yes | Yes |
| MAP-03 | Open a listing that has **no** coordinates. | The map area shows "Location not available — This listing has no pickup coordinates yet."; no pin, no fake Malang location. | Yes | Yes |
| MAP-04 | As a seller, open Add Product → tap the map icon. | The picker opens (starting at your position if permitted, otherwise a default center) with a draggable pin and search box. | Yes | Yes |
| MAP-05 | Drag the pin and watch the address label. | While dragging, only the raw coordinates update; **no address request fires** (check the browser/Android network log for Nominatim). Press "Describe" to fetch the address, or it is fetched once on Confirm. | Yes | Yes |
| MAP-06 | Tap "Use my current location" in the picker. | The pin jumps to your position (after the permission prompt). | Yes | Yes |
| MAP-07 | Confirm a location and publish the listing, then open the new row in Supabase → Table Editor → products. | `latitude`/`longitude` hold the chosen values **rounded to 3 decimals**. | Yes | Yes |
| MAP-08 | Try to publish without opening the picker. | Publishing is blocked with "Set a pickup location on the map before publishing."; no row is inserted. | Yes | Yes |
| LOC-01 | Open Home with location permission granted and GPS on. | Header shows "Near <area>"; cards show plausible distances ("1.2 km away"). | Yes | Yes |
| LOC-02 | Deny the permission (or block the site in the browser). | Header shows "Location not set"; a message explains why; a manual-location button appears. | Yes | Yes |
| LOC-03 | Permanently deny on Android (choose "Don't allow" twice) or disable GPS. | A clear message is shown; the manual-location fallback still works. | Partial | Yes |
| LOC-04 | Tap the manual-location button and pick a point. | Distances appear against the manually chosen point. | Yes | Yes |
| LOC-05 | Restart the app. | The buyer location is re-detected (or re-entered); it is **not** remembered between launches, and nothing about the buyer was stored on the server. | Yes | Yes |
| DIST-01 | Set the radius to 3 km, then 25 km, then All. | Each change updates the visible set; a listing with no coordinates is **excluded** when a radius is active and reappears on "All". | Yes | Yes |
| DIST-02 | Switch to "Nearest first". | Listings reorder by real distance; listings without coordinates go to the bottom. | Yes | Yes |
| DIST-03 | Compare a shown distance with a known distance (for example a map tool) for one listing. | They are close (the 3-decimal rounding adds at most ~110 m error). | Yes | Yes |
| CLUST-01 | Open the Nearby Map with several listings close together. | Overlapping pins merge into one green bubble showing a count. | Yes | Yes |
| CLUST-02 | Zoom out, then zoom in on that bubble. | Pins merge when zoomed out and split back into individual price pins when zoomed in. | Yes | Yes |
| CLUST-03 | Tap a cluster bubble. | A bottom sheet lists every product in the group; tapping a row opens that product; a "Zoom in" action is also available. | Yes | Yes |
| OFF-01 | Disconnect the network, then open a product with coordinates. | Tiles fail to load, the console logs "OSM tile failed to load", and the map remains usable with its attribution; no crash. | Yes | Yes |
| SEARCH-01 | In the picker, type a place and press Search. | Results appear only after the button press (no autocomplete); loading/no-results/error states are shown. | Yes | Yes |
| SEARCH-02 | Press Search twice quickly with the same query. | The second call is served from cache; requests to Nominatim are at least 1 second apart. | Yes | Yes |

### Chrome vs Android differences

- **Geolocation permission:** works on `http://localhost` on Chromium after the
  prompt, but the permission is often not persisted between restarts. Blocking
  the site in the browser is how you test the denied path on the web.
- **User-Agent:** `userAgentPackageName` is ignored on the web; the browser
  sends its own User-Agent and Referer. Verifying the `com.thrifty.thrifty`
  User-Agent requires Android (or a proxy on a device build).
- **GPS disabled / permanently denied:** only fully testable on Android.
- **Tiles:** need internet on both; offline shows the tile-error path.
