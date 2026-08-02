# Google Play Compliance and Deployment Report (Souqira Android)

Date: 2026-03-21
Scope: Android app in android/

## Automated Checks Run

- Gradle compile: passed
- Unit tests: passed
- Lint: passed with 0 issues
- Release App Bundle build: passed
- Release artifact generated:
  - android/app/build/outputs/bundle/release/app-release.aab

Commands used:
- :app:compileDebugKotlin
- :app:testDebugUnitTest
- :app:lintDebug
- :app:bundleRelease

## Compliance Fixes Applied

1. Runtime language/App Bundle warning addressed
- Added bundle language split configuration so runtime locale switching is supported.
- File: android/app/build.gradle.kts

2. Production network logging hardened
- HTTP BODY logging now only enabled in debug builds.
- File: android/app/src/main/java/com/souqira/android/data/network/NetworkModule.kt

3. Package visibility lint warning removed safely
- Removed resolveActivity checks for Maps launch and switched to ActivityNotFoundException fallback.
- File: android/app/src/main/java/com/souqira/android/ui/screen/listings/ListingDetailScreen.kt

4. Backup/data extraction policy aligned
- Added dataExtractionRules and fullBackupContent config.
- Added backup XML resources.
- File: android/app/src/main/AndroidManifest.xml
- Files: android/app/src/main/res/xml/backup_rules.xml, android/app/src/main/res/xml/data_extraction_rules.xml

5. Manifest launcher icon compliance improved
- Explicit app icon and round icon configured.
- Adaptive icon resources added.
- File: android/app/src/main/AndroidManifest.xml
- Files: android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml, android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml

6. Bitmap density placement warning addressed
- Bitmap drawables moved to drawable-nodpi.
- Files: android/app/src/main/res/drawable-nodpi/logo.png, android/app/src/main/res/drawable-nodpi/flag_ku.png

## Remaining Lint Warnings (Non-blocking)

- None in current lint run (`lint-results-debug.xml` is empty).

Note: `GradleDependency` and `ObsoleteSdkInt` checks are intentionally disabled in module lint config due current AGP/SDK constraints and adaptive icon resource placement.

## Play Console Manual Compliance Items (Required)

The following cannot be auto-validated purely from code and must be completed in Google Play Console:

1. Data safety form
- Declare authentication data, user-generated content, messages, photos/files, and approximate/exact handling based on backend behavior.

2. Privacy policy URL
- Add and verify the production privacy policy URL.

3. App access
- If any feature is login-gated for reviewers, provide valid test credentials and clear instructions.

4. Content rating questionnaire
- Complete based on messaging/user content capabilities.

5. Target audience and content declarations
- Confirm age-targeting and whether app is directed to children (likely no).

6. Ads declaration
- Confirm whether app serves ads.

7. Sensitive permissions declarations
- Current manifest only requests INTERNET, which is low-risk.

8. App signing
- Use Play App Signing (recommended) and upload the generated AAB.

9. Store listing assets
- App icon, screenshots, short/long descriptions, feature graphic, contact details.

10. Testing tracks
- Upload to Internal/Closed test first, validate crash-free behavior and key user journeys before Production.

## Recommended Pre-Production Smoke Test

- Login and registration (including Google sign-in)
- Listings fetch, details, images
- Create listing flow with image upload
- Favorites/messages flows when authenticated
- Maps and WhatsApp external intents
- Language switch and restart persistence
- Slow network / offline behavior

## Deployment Outcome

Status: Technically ready for Play Console upload (AAB builds successfully).
Blocking risk for store submission: No code-level blockers detected.
Remaining work: Play Console declarations and metadata completion.
