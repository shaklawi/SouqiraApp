import Foundation

// Test if GoogleSignIn is available
#if canImport(GoogleSignIn)
print("✅ GoogleSignIn framework is available")
#else
print("❌ GoogleSignIn framework is NOT available")
#endif
