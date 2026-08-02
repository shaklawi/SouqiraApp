# Google Play Console Submit Guide (Souqira Android)

Date: 2026-03-27

## 1) Go/No-Go Before Upload

Technical status is GO if all are true:

- Signed AAB exists:
  - android/app/build/outputs/bundle/release/app-release.aab
- Release pipeline passed locally:
  - :app:testDebugUnitTest
  - :app:lintRelease
  - :app:bundleRelease
- Lint release report has no issues:
  - android/app/build/reports/lint-results-release.xml

Current result in this repo: GO.

## 2) Upload Order in Play Console

1. Open app in Play Console (package: com.souqira.android)
2. Go to Testing -> Internal testing
3. Create release
4. Upload AAB:
   - android/app/build/outputs/bundle/release/app-release.aab
5. Add release notes (use template below)
6. Save -> Review release -> Start rollout to Internal testing

After internal validation is good:

7. Move to Closed testing (optional but recommended)
8. Then Production track

## 3) Release Notes Template (Copy/Paste)

Title: Internal test release 1.0.0

Notes:
- Initial public test build for Souqira Android.
- Includes authentication, listings, messaging baseline, and localization support.
- Stability and policy hardening updates included.

## 4) App Content Forms (Manual, Required)

Complete these in this order:

1. App access
- If reviewer login is required, provide test account and exact steps.

2. Ads
- Select "No" if app has no ads.

3. Content rating
- Complete questionnaire based on messaging/user content features.

4. Target audience
- Select real target age groups; set "not directed to children" if applicable.

5. Data safety
- Declare collected data categories and handling.

## 5) Data Safety Starter Template

Use this as a starting point and adjust to exact backend behavior:

Data categories likely involved:
- Personal info: email (account/auth)
- App activity / user content: listings, messages
- Photos/files (if listing image upload is supported)

Typical declarations to verify:
- Is data collected? Yes
- Is data shared with third parties? Only if true
- Is data encrypted in transit? Yes (HTTPS)
- Can users request deletion? If supported, mark accordingly

Important: only submit declarations that are true for your production behavior.

## 6) Store Listing Minimum Set

Prepare before Production:

- App name
- Short description
- Full description
- App icon (512x512)
- Phone screenshots (required sizes)
- Feature graphic (1024x500)
- Privacy policy URL
- Support email/contact

## 7) Final Production Gate

Ship to Production only when all are true:

- Internal track has successful install/open/auth smoke tests
- No critical crashes in pre-launch report
- All App Content sections are complete and green
- Data Safety and privacy policy are accurate
- Rollout plan chosen (for example 20% staged rollout)

## 8) Rollback/Recovery Plan

If Production issue occurs:

1. Halt staged rollout in Play Console
2. Build and upload hotfix AAB with incremented versionCode
3. Promote fixed release through Internal/Closed quickly

## 9) Security Reminders (Critical)

Keep private and backed up outside git:

- android/app/upload-keystore-v2.jks
- Credentials from android/keystore.properties

Do not commit signing files. They are already ignored by .gitignore.
