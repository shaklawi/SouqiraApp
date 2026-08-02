# Run Souqira on a Physical iPhone

## Important
You cannot run the iOS Simulator on an iPhone.
To test on your phone, run the app directly on the connected device from Xcode.

## 1) Prerequisites
- macOS with Xcode installed
- Apple ID signed in to Xcode
- iPhone connected by cable (or trusted over local network)
- This project dependencies installed:

```bash
pod install
```

## 2) Open the workspace
Open the CocoaPods workspace (not just the project):

```bash
open Souqira.xcworkspace
```

## 3) Set Signing (one-time)
1. Select target: Souqira
2. Open Signing & Capabilities
3. Enable Automatically manage signing
4. Select your Team (Apple ID)
5. Ensure a unique Bundle Identifier if needed (for example: com.souqira.app.yourname)

## 4) Trust this computer and enable Developer Mode
On iPhone:
1. Trust this Mac when prompted
2. Enable Developer Mode:
   - Settings > Privacy & Security > Developer Mode
3. Restart iPhone if prompted

## 5) Select device and run
1. In Xcode toolbar, choose your iPhone as run destination
2. Build and run with Cmd+R
3. If you see a certificate warning, trust the developer profile on iPhone:
   - Settings > General > VPN & Device Management

## 6) Google Sign-In notes
- Simulator tokens may fail backend validation in some environments.
- For reliable Google login testing, always use a physical iPhone.
- Make sure Info.plist contains valid Google client settings.

## 7) Background push notifications (messages)
For push when app is in background/closed, backend APNs config is required.

Set these backend environment variables:
- APNS_KEY_ID
- APNS_TEAM_ID
- APNS_BUNDLE_ID
- APNS_PRIVATE_KEY (single line with \n for new lines)
- APNS_USE_SANDBOX=true for development builds (false/omit for production)

After setting env vars:
1. Redeploy backend
2. Log in again in iPhone app (so device token is uploaded)
3. Send message from another account and verify push appears while app is backgrounded

## Common fixes
- Build fails for signing: re-select Team and clean build folder (Shift+Cmd+K)
- Device not shown: reconnect cable, unlock phone, trust computer again
- Pod issues: run `pod install` again and reopen `Souqira.xcworkspace`

## Fast dev flow (recommended)

Use the helper script from project root:

./dev_fast.sh

This will:
- run pod install
- open Souqira.xcworkspace
- remind you of the iPhone run steps in Xcode

Then in Xcode:
1) Select your iPhone as destination
2) Confirm Team in Signing & Capabilities
3) Press Run (Cmd+R)
