# Souqira App

🛍️ **Souqira** - Iraqi Business Marketplace iOS App

A modern iOS application for buying and selling businesses in Iraq, built with SwiftUI.

## Features

- 🏢 Browse businesses for sale across multiple categories
- 🌍 Search by Iraqi cities and regions
- 💰 Filter by price range
- ⭐ Save favorites
- 💬 In-app messaging
- 🔐 Authentication with Google Sign In
- 🌐 Multi-language support (English, Arabic, Kurdish)
- 🌙 Dark mode support

## Categories

- Restaurants
- Retail Stores
- Cafes
- Hotels
- Factories
- Warehouses
- Offices
- Land
- Buildings
- Apartments
- Houses
- Commercial Villas

## Tech Stack

- **SwiftUI** - Modern declarative UI framework
- **Google Sign In** - OAuth authentication
- **Combine** - Reactive programming
- **URLSession** - Networking
- **CocoaPods** - Dependency management
- **Keychain** - Secure token storage

## Installation

1. Clone the repository:
```bash
git clone https://github.com/YOUR_USERNAME/SouqiraApp.git
cd SouqiraApp
```

2. Install dependencies:
```bash
pod install
```

3. Open the workspace:
```bash
open Souqira.xcworkspace
```

4. Configure Google Sign In:
   - Get your Client ID from [Google Cloud Console](https://console.cloud.google.com)
   - Update `Info.plist` with your `GIDClientID` and reversed client ID

5. Build and run!

## Configuration

### Google Sign In Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project or select an existing one
3. Enable Google Sign-In API
4. Create OAuth 2.0 credentials (iOS)
5. Update `SouqiraApp/Info.plist`:
   - Replace `YOUR_GOOGLE_CLIENT_ID` with your actual Client ID
   - Replace `YOUR_REVERSED_CLIENT_ID` with your reversed client ID

### Backend API

The app connects to: `https://api.souqira.com`

Update the base URL in `NetworkManager.swift` if needed.

## Project Structure

```
SouqiraApp/
├── Models/              # Data models
├── Views/               # SwiftUI views
├── ViewModels/          # View models
├── Services/            # API and business logic
│   ├── APIService.swift
│   ├── NetworkManager.swift
│   ├── GoogleSignInManager.swift
│   └── MockDataService.swift
└── Assets.xcassets/     # Images and colors
```

## Requirements

- iOS 16.0+
- Xcode 14.0+
- CocoaPods

## Dependencies

- GoogleSignIn (~> 7.0)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.

## Author

Created with ❤️ for the Iraqi business community

---

**Note**: Make sure to configure your Google Client ID before running the app.
