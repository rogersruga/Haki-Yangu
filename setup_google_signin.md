# Google Sign-In Setup Guide

## Current Issue
Your app shows "Google Sign-In hasn't been configured properly" because the Firebase project needs proper Android OAuth client configuration.

## Step-by-Step Fix

### 1. Get Your SHA-1 Fingerprint
Your debug SHA-1 fingerprint is: `87:1E:05:28:91:26:52:5A:AF:0A:3C:32:9A:45:5F:C3:CE:06:AC:44`

### 2. Configure Firebase Console

1. **Go to Firebase Console**: https://console.firebase.google.com/
2. **Select your project**: "haki-yangu"
3. **Go to Project Settings** (gear icon)
4. **Select "Your apps" tab**
5. **Find your Android app** (com.innoloom.hakiyangu)
6. **Add SHA-1 fingerprint**:
   - Click "Add fingerprint"
   - Paste: `87:1E:05:28:91:26:52:5A:AF:0A:3C:32:9A:45:5F:C3:CE:06:AC:44`
   - Click "Save"

### 3. Enable Google Sign-In

1. **Go to Authentication** in Firebase Console
2. **Click "Sign-in method" tab**
3. **Enable Google** provider
4. **Add your email** as an authorized domain if needed

### 4. Download New google-services.json

1. **After adding SHA-1**, go back to Project Settings
2. **Download the new google-services.json** file
3. **Replace** the file in `android/app/google-services.json`

### 5. Alternative: Use Email/Password Only

If Google Sign-In continues to have issues, you can disable it temporarily:

```dart
// In signup_screen.dart, comment out the Google Sign-In button
// Or add this check:
if (false) { // Disable Google Sign-In temporarily
  // Google sign up button code
}
```

## Quick Test Commands

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk --debug

# Install and test
adb install build/app/outputs/flutter-apk/app-debug.apk

# Monitor logs
flutter logs
```

## Expected Behavior After Fix

- Google Sign-In button should open Google account picker
- You should be able to select your Google account
- App should successfully authenticate and navigate to home screen

## If Still Not Working

The app now has detailed logging. Check the logs for specific error messages:
- 🔵 Blue messages = Process steps
- 🟢 Green messages = Success
- 🔴 Red messages = Errors
- 🟡 Yellow messages = Warnings
