# THRIFTY Supabase setup

This guide sets up the Flutter app against a teammate's own Supabase project. It contains no project URL, API key, database password, or service-role key.

## 1. Create and configure a Supabase project

1. Create a project on the **Free** plan. Use the same organization and region as the team's current project where possible; project regions cannot be changed later.
2. Save the database password in a password manager. Never put it in Flutter configuration or Git.
3. In **Authentication → Sign In / Providers → Email**, enable Email/Password and turn **Confirm email** off for this prototype. Set a minimum password length of 8 or more. The role is chosen at registration, so a user can self-select `seller`; that is an accepted prototype limitation.
4. In **Project Settings → API**, copy the Project URL and the Publishable key (or legacy anon key). The app must use only that public client key. Never use `service_role` or a secret key in the app, a local config file, or Git.
5. In **Project Settings → API → Data API**, make sure the Data API is enabled. The project was set up with automatic exposure of new tables disabled and automatic RLS enabled; keep those protections. The SQL creates the intended `public` tables and uses a non-exposed `private` helper schema.

## 2. Create the database schema and policies

In the Supabase Dashboard, select the new project, open **SQL Editor**, and run the repository files in this order:

1. Open `supabase/sql/001_schema.sql`, copy all of it into a new SQL Editor query, and run it. It creates the profile/product tables, constraints, triggers, indexes, and helper function.
2. Open `supabase/sql/002_rls.sql`, paste it into a new query, and run it. It grants the required access and adds row-level security policies.
3. Open `supabase/sql/003_tests.sql`, paste it into a new query, and run it. Its dashboard-safe checks are read-only and roll back. Follow its comments for the separate real buyer/seller ownership checks after you have test accounts. For expected-denial SQL statements, use separate transactions as its instructions describe.

Expected result: `public.profiles` and `public.products` appear in **Table Editor**, RLS is enabled on both, and the policy checks complete without errors. Do not rerun these files in a different Supabase project by mistake.

## 3. Create the product photo bucket and policies

1. In **Storage → New bucket**, create a bucket named `product-images`.
2. Set it to **Public**, set the per-file limit to **5 MiB**, and allow `image/jpeg`, `image/png`, and `image/webp`. Public means anyone who has an image URL can view that image; upload and delete remain policy-controlled.
3. Confirm the bucket appears in Storage.
4. In **SQL Editor**, run `supabase/sql/004_storage.sql`. It creates seller-folder `SELECT`, `INSERT`, and `DELETE` policies on `storage.objects`. The first folder segment must be the signed-in seller's Auth user ID, and the role helper must report `seller`.
5. In **Storage → Policies**, confirm the three policies exist for `storage.objects`.

The app writes files under `<seller-auth-uuid>/<generated-product-uuid>/<number>.<extension>` and stores their public URLs in `products.image_urls`.

## 4. Configure the local Flutter app

From the repository's `frontend` folder in PowerShell:

```powershell
Copy-Item .\supabase.env.example.json .\supabase.env.json
```

Open `frontend/supabase.env.json` locally and replace the blank values for `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` with the values copied from **Project Settings → API**. Do not paste the values in chat or commit this file. The local file is ignored by `frontend/.gitignore`; keep `supabase.env.example.json` blank and committed so each teammate can make their own config.

Run the app from the `frontend` directory:

```powershell
flutter pub get
flutter analyze
flutter run -d chrome --dart-define-from-file=.\supabase.env.json
```

To build an Android debug APK with the same local config:

```powershell
flutter build apk --debug --dart-define-from-file=.\supabase.env.json
```

Never add the database password, `service_role` key, SMTP credentials, or any secret to either JSON file. `supabase.env.json` should contain only the project URL and Publishable/anon key.

## 5. Supabase Free-plan notes

Checked against Supabase's official documentation on 2026-11-16:

- Free currently includes 500 MB database size, 1 GB Storage, 5 GB egress, 5 GB cached egress, and a 50 MB global maximum upload size. THRIFTY's bucket limit is deliberately lower at 5 MiB per image.
- Free projects may pause after about 7 days with too little database activity. Supabase currently allows a paused project to be restored for up to 1 year. Check the dashboard/email warning before a presentation and allow time to resume it.
- Free does not include automatic daily database backups. Keep the SQL files in Git; also export important project data and Storage objects separately if they need preservation. SQL files recreate the schema and policies, but do not back up user rows or uploaded images.
- The default Supabase Auth sender only delivers to organization team-member addresses and currently allows 2 messages per hour. Sending password reset messages to ordinary users requires custom SMTP. THRIFTY's password-reset screen is UI-only and does not send email.

These quotas can change; check [Supabase pricing](https://supabase.com/pricing), [project pausing](https://supabase.com/docs/guides/platform/free-project-pausing), and [database backups](https://supabase.com/docs/guides/platform/backups) before relying on them.

## 6. Final manual acceptance test table

Use disposable test accounts and listings. Keep the buyer, seller A, and seller B UUIDs private. Do not use a production account for destructive tests.

| ID | Steps | Expected result |
|---|---|---|
| AUTH-01 | Register a buyer with a valid email, display name, role, and password. Check Authentication → Users and `public.profiles`. | Auth user and profile exist; profile role is `buyer`; app proceeds only after successful registration. |
| AUTH-02 | Register a seller with a valid email, display name, role, and password. | Profile role is `seller`; the shared app shows seller actions. |
| AUTH-03 | Try registration with no selected role or an unsupported role through the app/database path. | App blocks missing role; database rejects an unsupported role. |
| AUTH-04 | Register a duplicate email. | Registration fails with a clear error; no second account/profile is created. |
| AUTH-05 | Register with a malformed email and a password below the configured minimum. | Each is rejected with a clear validation/auth message. |
| AUTH-06 | Log in with an unregistered email and with a registered email plus wrong password. | Both are rejected; user stays signed out. |
| AUTH-07 | Turn off network, try login or signup, then restore network. | Operation fails with a connection message; app remains usable and does not show false success. |
| AUTH-08 | Log in, reload/restart the app, then log out. | Session restores after restart; logout signs out and returns to the signed-out flow. |
| AUTH-09 | On login, tap **Forgot password?**, submit an email, and inspect the message. | Reset screen opens; it says reset is unavailable and no email was sent. No recovery email is sent. |
| ROLE-01 | Sign in as buyer and inspect Home/Profile and protected seller routes. | Buyer cannot access Add Product or My Listings. A protected action offers login where applicable. |
| ROLE-02 | As buyer, attempt product insertion through SQL Editor using the documented authenticated role and buyer UUID. Then, while signed in to the app as that buyer, make the temporary direct Supabase client insert described below. | Both real policy checks reject the insert; no row is created. |
| ROLE-03 | As a user, try to change your own `profiles.role` in the app and through the documented SQL policy test. | Role remains unchanged; database denies role modification. |
| PROD-01 | As seller A, create a listing with valid details and one to six supported photos. Check `public.products` and Storage. | One listing is created; `image_urls` contains the public URLs; files are under seller A's UUID folder and generated product folder. |
| PROD-02 | View seller A's listing as a buyer in Home, Search, Product Details, and cart; view it as seller A in My Listings. | Correct product photos render in each view. |
| PROD-03 | Try to publish with an unsupported/oversized photo or with network disabled during upload. | Publish fails; the form remains; no half-saved product row appears. Any files uploaded before the failure are cleaned up when the request can reach Storage. |
| PROD-04 | As seller B, try the documented SQL update/delete tests against seller A's active listing. | Seller B's attempts affect zero rows; seller A can edit, mark sold, and delete only their own listing. |
| PROD-05 | Try to change `products.seller_id` after creating a product. | Database prevents changing ownership. |
| PROD-06 | Open a saved public photo URL in a signed-out browser. | Image is readable because the bucket is public; do not store private photos there. |
| CLEAN-01 | Search source, Android configuration, `pubspec.lock`, and Flutter's generated plugin metadata for `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, Firebase initialization, and Google Services plugin/config references. | No Firebase source/config/build/dependency references remain after `flutter pub get`. |

For the real-client part of `ROLE-02`, temporarily call this from a debug-only method while signed in as the buyer. Use the app's normal Supabase client and the buyer's own UUID; do not use a service-role key. The request should throw a PostgREST/RLS error and create no row. Remove the temporary call after checking:

```dart
await Supabase.instance.client.from('products').insert({
  'seller_id': Supabase.instance.client.auth.currentUser!.id,
  'name': 'Buyer RLS test',
  'brand': 'Test',
  'size': 'M',
  'category': 'Shirt',
  'price': 1000,
  'description': 'Temporary test row',
  'pickup_location': 'Test',
  'latitude': -7.9465,
  'longitude': 112.6156,
  'image_urls': <String>[],
  'ai_grade': 'A',
  'ai_confidence': 0.9,
  'final_grade': 'A',
  'grade_overridden': false,
  'status': 'active',
});
```

Known prototype limitations: users choose their own buyer/seller role at signup; pickup coordinates are fixed; the AI grade/confidence is supplied by the client and can be falsified; photos are public and are not automatically removed from Storage when a listing row is deleted; password reset is not implemented; Free projects may pause and have no automatic daily database backups.

## 7. Tests that are practical later

The existing `flutter_test` dependency can support unit tests for form validation, grade mapping, and product-row parsing, plus widget tests for registration/login validation and reset-screen navigation/message. For authorization, use an injectable repository interface with a fake to test UI behavior; a fake cannot prove real Supabase RLS. Keep the two-real-account SQL/app checks above for database policies.

No mocking dependency was added in this cleanup. `mocktail` or a Supabase-specific fake/mock package could be evaluated later; current package versions and compatibility with the installed Supabase Flutter version are **UNVERIFIED** and were not installed.
