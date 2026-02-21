# 🚀 App Store Submission Checklist for Souqira

## ✅ Completed Preparatory Steps

### 1. Privacy Permissions ✅
All required privacy usage descriptions have been added to `Info.plist`:
- ✅ NSCameraUsageDescription
- ✅ NSPhotoLibraryUsageDescription  
- ✅ NSLocationWhenInUseUsageDescription
- ✅ NSUserTrackingUsageDescription
- ✅ NSContactsUsageDescription
- ✅ NSMicrophoneUsageDescription

### 2. Project Configuration ✅
- ✅ Bundle ID: `com.souqira.app`
- ✅ Marketing Version: `1.0.0`
- ✅ Build Number: `1`
- ✅ API Endpoint: `https://api.souqira.com`

### 3. AppIcon Configuration ✅
- ✅ Contents.json updated with all required icon sizes
- ⚠️ **ACTION NEEDED**: Add actual app icon images (see below)

---

## 🔴 CRITICAL: Required Actions Before App Store Submission

### 1. Add Apple Developer Team ID
📝 **File to edit:** `project.yml` (line 22)

```yaml
DEVELOPMENT_TEAM: "XXXXXXXXXX"  # Replace with your 10-character Team ID
```

**How to find your Team ID:**
1. Go to https://developer.apple.com/account
2. Click "Membership" in the sidebar
3. Copy your Team ID (10 characters, e.g., "AB12CD34EF")

---

### 2. Generate and Add App Icons

You need to create app icons in the following sizes and add them to:
`SouqiraApp/Assets.xcassets/AppIcon.appiconset/`

**Required icon files:**
- `AppIcon-1024x1024.png` (1024×1024px) - **MOST IMPORTANT**
- `AppIcon-20x20.png` (20×20px)
- `AppIcon-20x20@2x.png` (40×40px)
- `AppIcon-20x20@2x-1.png` (40×40px)
- `AppIcon-20x20@3x.png` (60×60px)
- `AppIcon-29x29.png` (29×29px)
- `AppIcon-29x29@2x.png` (58×58px)
- `AppIcon-29x29@2x-1.png` (58×58px)
- `AppIcon-29x29@3x.png` (87×87px)
- `AppIcon-40x40.png` (40×40px)
- `AppIcon-40x40@2x.png` (80×80px)
- `AppIcon-40x40@2x-1.png` (80×80px)
- `AppIcon-40x40@3x.png` (120×120px)
- `AppIcon-60x60@2x.png` (120×120px)
- `AppIcon-60x60@3x.png` (180×180px)
- `AppIcon-76x76.png` (76×76px)
- `AppIcon-76x76@2x.png` (152×152px)
- `AppIcon-83.5x83.5@2x.png` (167×167px)

**Tools to generate icons:**
- Online: https://appicon.co/ (Upload 1024×1024 image, download all sizes)
- macOS: Use Preview or Sketch to export different sizes
- Command line: Use ImageMagick or sips

**Design guidelines:**
- No transparency (use solid background)
- No rounded corners (iOS adds them automatically)
- Simple, recognizable design
- Test at small sizes (20×20px should still be clear)

---

### 3. Create App Store Connect Listing

1. **Go to App Store Connect:** https://appstoreconnect.apple.com
2. **Create New App:**
   - Bundle ID: `com.souqira.app`
   - App Name: `Souqira`
   - Primary Language: Choose (English, Arabic, or Kurdish)
   - SKU: `souqira-app-001`

3. **Prepare App Information:**
   - **Category:** Shopping or Business
   - **Subtitle:** (35 characters max) e.g., "Buy & Sell Businesses"
   - **Description:** Write compelling description about Souqira
   - **Keywords:** business, marketplace, Iraq, Erbil, listings, etc.
   - **Support URL:** Your support website
   - **Marketing URL:** (optional) Your marketing website
   - **Privacy Policy URL:** **REQUIRED** - Create privacy policy

4. **Screenshots Required:**
   - iPhone 6.7" Display (iPhone 14 Pro Max):
     - At least 3 screenshots (up to 10)
     - Size: 1290×2796px or 2796×1290px
   - iPhone 6.5" Display (iPhone 11 Pro Max):
     - At least 3 screenshots
     - Size: 1242×2688px or 2688×1242px
   - iPad Pro (12.9") - If supporting iPad:
     - At least 3 screenshots
     - Size: 2048×2732px or 2732×2048px

5. **App Review Information:**
   - Demo account credentials (if login required)
   - Contact information
   - Notes for reviewer

---

### 4. Privacy Policy (REQUIRED)

You **MUST** have a privacy policy URL. Create a page explaining:
- What data you collect (location, photos, contacts, etc.)
- How you use the data
- How users can delete their data
- Third-party services (Google Sign-In, etc.)

**Host it on:**
- Your website
- GitHub Pages (free)
- Privacy policy generators online

---

### 5. Build & Archive for Release

After adding Team ID:

```bash
cd /Users/user291714/SouqiraApp

# Generate Xcode project from project.yml
xcodegen generate

# Clean build folder
xcodebuild clean -workspace Souqira.xcworkspace -scheme Souqira

# Build for Release
xcodebuild -workspace Souqira.xcworkspace \
  -scheme Souqira \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  archive -archivePath ./build/Souqira.xcarchive

# Export for App Store (requires export options plist)
xcodebuild -exportArchive \
  -archivePath ./build/Souqira.xcarchive \
  -exportPath ./build \
  -exportOptionsPlist ExportOptions.plist
```

Or use Xcode GUI:
1. Open `Souqira.xcworkspace` in Xcode
2. Select "Any iOS Device" as destination
3. Product → Archive
4. Organizer window → Distribute App → App Store Connect

---

### 6. Testing Checklist

Before submission, test:
- ✅ All screens load correctly
- ✅ Google Sign-In works
- ✅ Listings load from API
- ✅ Filters work correctly
- ✅ Location permission request works
- ✅ Camera/photo library access works
- ✅ App doesn't crash on launch
- ✅ Test on different iOS versions (16.0+)
- ✅ Test on different device sizes

---

### 7. TestFlight (Optional but Recommended)

Upload to TestFlight first for beta testing:
1. Upload build to App Store Connect
2. Wait for processing (~10-30 minutes)
3. Add internal/external testers
4. Collect feedback
5. Fix issues
6. Upload new build if needed

---

## 📋 Quick Start Commands

### Generate Xcode Project (if using XcodeGen):
```bash
cd /Users/user291714/SouqiraApp
xcodegen generate
```

### Open in Xcode:
```bash
open Souqira.xcworkspace
```

### Test Build (Simulator):
```bash
xcodebuild -workspace Souqira.xcworkspace \
  -scheme Souqira \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  build
```

---

## 🔗 Important Links

- **Apple Developer:** https://developer.apple.com/account
- **App Store Connect:** https://appstoreconnect.apple.com
- **App Review Guidelines:** https://developer.apple.com/app-store/review/guidelines/
- **Human Interface Guidelines:** https://developer.apple.com/design/human-interface-guidelines/
- **App Store Screenshots Guide:** https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications

---

## 📞 Support

If you encounter issues during submission:
1. Check Apple's System Status: https://developer.apple.com/system-status/
2. Review Apple Developer Forums: https://developer.apple.com/forums/
3. Contact Apple Developer Support: https://developer.apple.com/contact/

---

## ⚠️ Common Rejection Reasons to Avoid

1. **Missing Privacy Policy** - Must have URL
2. **Insufficient App Description** - Be detailed
3. **Crashes on Launch** - Test thoroughly
4. **Missing Demo Account** - Provide if login required
5. **Misleading Screenshots** - Show actual app functionality
6. **Privacy Violations** - Follow data collection guidelines
7. **Broken Links** - Test all URLs
8. **Incomplete Metadata** - Fill all required fields

---

## 🎯 Estimated Timeline

1. **Setup (Today):** Add Team ID, generate icons → 1-2 hours
2. **App Store Connect:** Create listing, add metadata → 2-3 hours
3. **Screenshots:** Create and upload → 1-2 hours
4. **Archive & Upload:** Build and submit → 1 hour
5. **App Review:** Apple's review process → 1-3 days (average)
6. **Release:** Manual or automatic after approval

**Total:** ~1 week from preparation to App Store

---

## ✅ Final Checklist Before Submit

- [ ] Team ID added to project.yml
- [ ] App icons generated and added
- [ ] Privacy policy URL created
- [ ] App Store Connect listing completed
- [ ] Screenshots captured and uploaded
- [ ] Demo account created (if needed)
- [ ] Tested on real device
- [ ] Tested all features work
- [ ] Archive created successfully
- [ ] Uploaded to App Store Connect
- [ ] Submitted for review

---

**Good luck with your App Store submission! 🚀**
