# Souqira Android

Android version of Souqira built with Kotlin and Jetpack Compose, mirroring the iOS app architecture and backend contract.

## Implemented baseline

- App shell with bottom tabs: Home, Listings, Messages, Profile
- Authentication flow scaffold (email/password login)
- Listings flow against production API (`https://api.souqira.com`)
- Basic filters (search + category)
- Conversations + messages flow against backend
- Profile state based on authenticated user
- Token persistence with DataStore
- Shared API model parity for key entities:
  - `User`
  - `BusinessListing`
  - `Conversation`
  - `Message`
  - `AppNotification`

## Implemented now (parity expansion)

- Google Sign-In integration path in Android auth screen
  - Uses Google ID token and sends it to `/api/auth/google/token`
  - Web client ID is read from `app/src/main/res/values/strings.xml` key `google_web_client_id`
- Listing detail screen with:
  - Fresh detail fetch by listing id
  - Favorite toggle
  - Call and WhatsApp quick actions
- Favorites flow:
  - Dedicated Favorites tab
  - Remove from favorites
  - Open listing detail from favorites
- Create Listing flow:
  - Validation for required fields
  - Category and region selectors
  - Image picker (up to 5)
  - Multipart upload to `/api/listing/create` when images exist
  - JSON fallback create when no images are selected

## Tech stack

- Kotlin
- Jetpack Compose
- Navigation Compose
- Retrofit + OkHttp
- DataStore Preferences
- Coroutines + StateFlow

## Project structure

- `app/src/main/java/com/souqira/android/data`: models, network, repositories
- `app/src/main/java/com/souqira/android/ui`: Compose UI and screens
- `app/src/main/java/com/souqira/android/ui/viewmodel`: view models
- `app/src/main/java/com/souqira/android/domain`: app container

## Run

1. Open `android` folder in Android Studio.
2. Let Gradle sync.
3. Ensure Java 17 is installed and selected for Gradle (required).
3. Run app on emulator/device with Android 8.0+.

## Google Sign-In setup

1. Create/get Android + Web OAuth clients in Google Cloud Console.
2. Put your Web client ID in `app/src/main/res/values/strings.xml`:
  - `google_web_client_id`
3. Ensure backend accepts/validates the same Google audience.

If `google_web_client_id` is left as placeholder, Google Sign-In will not start.

## 1:1 parity roadmap

1. Add localization (English/Arabic/Kurdish) and RTL switching.
2. Add push notifications and backend device-token registration.
3. Improve message UX to match iOS design behavior.
4. Add pagination triggers and pull-to-refresh behavior to listings.
5. Add visual design parity with iOS branding and production QA.
