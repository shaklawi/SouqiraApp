# Android 15 Edge-to-Edge Test Script (Souqira)

## Scope
Use this script to validate that edge-to-edge behavior is correct on Android 15 after enabling edge-to-edge in the app.

## Test Environment
- Device A: Android 15, gesture navigation enabled.
- Device B (or same device): Android 15, 3-button navigation enabled.
- Orientation: portrait and landscape.
- Build: latest release build generated for upload.

## Test Data
- Logged-out state available.
- Logged-in state available.
- At least 1 listing with images.
- At least 1 chat conversation (if possible).

## Execution Rules
- For each test case, mark Pass/Fail.
- If Fail: add screenshot, short note, and screen name.
- Repeat critical cases in both navigation modes (gesture + 3-button).

---

## TC-01 App Launch and Global Chrome
### Steps
1. Launch app on Android 15.
2. Stay on first visible screen for 10 seconds.
3. Rotate to landscape and back to portrait.

### Expected
- No content hidden behind status bar.
- No content hidden behind navigation bar.
- No flicker, jump, or clipped UI during rotate.

---

## TC-02 Home Screen Insets
### Steps
1. Open Home tab.
2. Scroll from top to bottom.
3. Observe top title area and bottom tab bar area.

### Expected
- Top content has correct spacing from status bar/cutout.
- Bottom content is not blocked by system nav area.
- Bottom tab bar remains fully visible and clickable.

---

## TC-03 Listings Screen Insets + Scroll
### Steps
1. Open Listings/Cities tab.
2. Scroll list fast and slow.
3. Tap into one listing and go back.

### Expected
- List items are never clipped under top/bottom system bars.
- Back navigation returns without layout shift.

---

## TC-04 Listing Detail Screen
### Steps
1. Open a listing detail page.
2. Swipe image gallery.
3. Scroll through description and location section.
4. Tap map-related actions if present.

### Expected
- Gallery and action buttons are fully visible.
- Bottom action/contact area is not overlapped by nav bar.
- No overlap with status bar at top.

---

## TC-05 Create Listing Screen (Critical)
### Steps
1. Open Create Listing.
2. Tap each input field in order:
   - Title
   - Description
   - Price
   - Phone
   - WhatsApp
   - Address
3. Open keyboard on each field.
4. Scroll while keyboard is open.
5. Close keyboard.

### Expected
- Focused field is always visible.
- Keyboard does not cover active field.
- Helper text/hints remain readable.
- Submit/create action stays reachable.

---

## TC-06 Messages Screen + Keyboard (Critical)
### Steps
1. Open Messages.
2. Open a conversation.
3. Tap message input to open keyboard.
4. Type multi-line text.
5. Send message.

### Expected
- Input box and send button stay above keyboard.
- Last messages remain visible; no clipping under system bars.
- No sudden jump in layout when keyboard opens/closes.

---

## TC-07 Profile/Auth Screens
### Steps
1. Test logged-out profile flow (login/auth screen).
2. Test logged-in profile flow.
3. Open language selector and close.

### Expected
- All buttons are fully tappable at top and bottom.
- No overlap in status/nav bar zones.

---

## TC-08 Dialog/Sheet Risk Check
### Steps
1. Trigger any in-app dialogs or sheets (if available).
2. Inspect top and bottom spacing.

### Expected
- Dialog/sheet content does not clash with system bars.
- Dismiss actions remain visible and tappable.

---

## TC-09 Navigation Mode Regression
### Steps
1. Run TC-01 to TC-08 on gesture navigation.
2. Switch to 3-button navigation.
3. Re-run TC-01 to TC-08.

### Expected
- Same visual correctness in both navigation modes.
- No new overlap issues in 3-button mode.

---

## TC-10 Orientation Regression
### Steps
1. On Home, Listings, Create Listing, Messages:
2. Rotate portrait -> landscape -> portrait.

### Expected
- Insets recompute correctly.
- No stuck padding/margin values.
- No clipped top/bottom controls.

---

## Defect Logging Template
Use this for each failed case:

- Test Case ID:
- Screen:
- Device + Android version:
- Navigation mode (Gesture / 3-button):
- Orientation:
- Steps to reproduce:
- Actual result:
- Expected result:
- Screenshot/video:
- Severity (Low/Medium/High):

---

## Sign-off Summary
- Total cases:
- Passed:
- Failed:
- Blockers:
- Ready for Play upload: Yes / No

Notes:
- If only Play advisory remains but all test cases pass visually and functionally, release can proceed.
