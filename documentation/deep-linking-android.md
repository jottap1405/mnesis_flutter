# Android Deep Linking Configuration

## Overview

This document describes the Android deep linking configuration for the Mnesis Flutter application. Deep linking allows the app to be opened directly to specific screens from external sources like web browsers, QR codes, or other apps.

## Configuration

### AndroidManifest.xml Changes

The following intent filters have been added to the `android/app/src/main/AndroidManifest.xml` file to enable deep linking:

### 1. Custom Scheme Links (mnesis://)

Custom scheme links use the `mnesis://` protocol and work without domain verification. These are configured with separate intent filters for each route to ensure proper routing:

- `mnesis://chat` - Opens the chat screen
- `mnesis://new` - Opens the new consultation screen
- `mnesis://operation` - Opens the operation screen
- `mnesis://admin` - Opens the admin screen

### 2. App Links (https://mnesis.app)

App Links use HTTPS and require domain verification. These are configured with `android:autoVerify="true"`:

- `https://mnesis.app/chat` - Opens the chat screen
- `https://mnesis.app/new` - Opens the new consultation screen
- `https://mnesis.app/operation` - Opens the operation screen
- `https://mnesis.app/admin` - Opens the admin screen

## Testing Deep Links

### Prerequisites

- Android device or emulator with the app installed
- ADB (Android Debug Bridge) installed on your development machine

### Testing Custom Scheme Links (mnesis://)

Use the following ADB commands to test custom scheme deep links:

```bash
# Test chat screen
adb shell am start -W -a android.intent.action.VIEW -d "mnesis://chat" com.mnesis.mnesis_flutter

# Test new consultation screen
adb shell am start -W -a android.intent.action.VIEW -d "mnesis://new" com.mnesis.mnesis_flutter

# Test operation screen
adb shell am start -W -a android.intent.action.VIEW -d "mnesis://operation" com.mnesis.mnesis_flutter

# Test admin screen
adb shell am start -W -a android.intent.action.VIEW -d "mnesis://admin" com.mnesis.mnesis_flutter
```

### Testing App Links (https://mnesis.app)

Use the following ADB commands to test HTTPS app links:

```bash
# Test chat screen
adb shell am start -W -a android.intent.action.VIEW -d "https://mnesis.app/chat" com.mnesis.mnesis_flutter

# Test new consultation screen
adb shell am start -W -a android.intent.action.VIEW -d "https://mnesis.app/new" com.mnesis.mnesis_flutter

# Test operation screen
adb shell am start -W -a android.intent.action.VIEW -d "https://mnesis.app/operation" com.mnesis.mnesis_flutter

# Test admin screen
adb shell am start -W -a android.intent.action.VIEW -d "https://mnesis.app/admin" com.mnesis.mnesis_flutter
```

### Testing from a Web Page

You can also test deep links by creating a simple HTML file:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Mnesis Deep Link Test</title>
</head>
<body>
    <h2>Custom Scheme Links</h2>
    <ul>
        <li><a href="mnesis://chat">Open Chat</a></li>
        <li><a href="mnesis://new">New Consultation</a></li>
        <li><a href="mnesis://operation">Operation</a></li>
        <li><a href="mnesis://admin">Admin</a></li>
    </ul>

    <h2>App Links</h2>
    <ul>
        <li><a href="https://mnesis.app/chat">Open Chat</a></li>
        <li><a href="https://mnesis.app/new">New Consultation</a></li>
        <li><a href="https://mnesis.app/operation">Operation</a></li>
        <li><a href="https://mnesis.app/admin">Admin</a></li>
    </ul>
</body>
</html>
```

## App Links Verification

For HTTPS app links to work properly without showing a disambiguation dialog, you need to:

1. **Host an assetlinks.json file** on your server at:
   ```
   https://mnesis.app/.well-known/assetlinks.json
   ```

2. **Content of assetlinks.json:**
   ```json
   [
     {
       "relation": ["delegate_permission/common.handle_all_urls"],
       "target": {
         "namespace": "android_app",
         "package_name": "com.mnesis.mnesis_flutter",
         "sha256_cert_fingerprints": [
           "YOUR_APP_SIGNING_CERTIFICATE_SHA256_FINGERPRINT"
         ]
       }
     }
   ]
   ```

3. **Get your app's SHA256 fingerprint:**
   ```bash
   # For debug certificate
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

   # For release certificate
   keytool -list -v -keystore your-release-key.keystore -alias your-alias
   ```

4. **Verify the assetlinks.json file:**
   Use Google's Digital Asset Links API to verify:
   ```
   https://digitalassetlinks.googleapis.com/v1/statements:list?source.web.site=https://mnesis.app&relation=delegate_permission/common.handle_all_urls
   ```

## GoRouter Integration

The app uses `go_router` for navigation, which automatically handles deep links. The routes are defined in:
- `/lib/core/router/app_router.dart` - Main router configuration
- `/lib/core/router/route_paths.dart` - Route path constants

GoRouter matches incoming deep link paths with the configured routes automatically. No additional code is needed for basic deep link handling.

## Troubleshooting

### Deep links not working

1. **Check app installation:**
   ```bash
   adb shell pm list packages | grep mnesis
   ```
   Should output: `package:com.mnesis.mnesis_flutter`

2. **Verify intent filters:**
   ```bash
   adb shell dumpsys package com.mnesis.mnesis_flutter | grep -A 10 "intent filters"
   ```

3. **Check for conflicts:**
   Other apps might handle the same links. Clear defaults:
   ```bash
   adb shell pm clear-defaults com.mnesis.mnesis_flutter
   ```

### App Links not auto-verifying

1. **Check autoVerify attribute:**
   Ensure `android:autoVerify="true"` is set on the HTTPS intent filter

2. **Verify assetlinks.json is accessible:**
   ```bash
   curl https://mnesis.app/.well-known/assetlinks.json
   ```

3. **Check certificate fingerprint:**
   The SHA256 fingerprint in assetlinks.json must match your app's signing certificate

4. **Force verification (Android 12+):**
   ```bash
   adb shell pm verify-app-links --re-verify com.mnesis.mnesis_flutter
   adb shell pm get-app-links com.mnesis.mnesis_flutter
   ```

### Deep links open in browser instead

1. **For custom scheme:** Should always open the app if installed
2. **For HTTPS links:** Requires proper app link verification
3. **Clear browser defaults if needed:**
   Settings → Apps → Browser → Open by default → Clear defaults

## Platform Compatibility

- **Minimum Android Version:** As defined in `minSdk` (check build.gradle.kts)
- **App Links (autoVerify):** Android 6.0 (API level 23) and higher
- **Custom Scheme Links:** All Android versions

## Security Considerations

1. **Custom schemes** (`mnesis://`) are not secure and can be claimed by any app
2. **App Links** (HTTPS) are more secure as they require domain verification
3. **Sensitive operations** should validate the user's authentication state after deep link navigation
4. **Never pass sensitive data** in deep link URLs

## Related Documentation

- [Android App Links Documentation](https://developer.android.com/training/app-links)
- [Flutter Deep Linking](https://docs.flutter.dev/development/ui/navigation/deep-linking)
- [go_router Deep Linking](https://pub.dev/packages/go_router#deep-linking)

## Implementation Status

- ✅ AndroidManifest.xml configured with intent filters
- ✅ Custom scheme links (mnesis://) configured
- ✅ App Links (https://mnesis.app) configured with autoVerify
- ✅ All four main routes supported (chat, new, operation, admin)
- ⏳ assetlinks.json deployment (pending production setup)
- ⏳ Production certificate fingerprint (pending release signing)