# iOS Deep Linking Configuration

## Overview

This document describes the iOS deep linking configuration for the Mnesis Flutter application. The app supports both custom URL schemes (`mnesis://`) and Universal Links (`https://mnesis.app`) for seamless navigation.

## Configuration Files

### 1. Info.plist Configuration

The `ios/Runner/Info.plist` file has been configured with the following deep linking settings:

```xml
<!-- Enable Flutter deep linking -->
<key>FlutterDeepLinkingEnabled</key>
<true/>

<!-- Custom URL scheme -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.mnesis.mnesis-flutter</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>mnesis</string>
        </array>
    </dict>
</array>

<!-- Associated Domains for Universal Links -->
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:mnesis.app</string>
</array>
```

### 2. Runner.entitlements Configuration

The `ios/Runner/Runner.entitlements` file enables Universal Links support:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.associated-domains</key>
    <array>
        <string>applinks:mnesis.app</string>
    </array>
</dict>
</plist>
```

## Supported Deep Link Patterns

### Custom URL Scheme
- `mnesis://chat` - Navigate to chat screen
- `mnesis://new` - Navigate to new operation screen
- `mnesis://operation` - Navigate to operation list screen
- `mnesis://admin` - Navigate to admin screen

### Universal Links (HTTPS)
- `https://mnesis.app/chat` - Navigate to chat screen
- `https://mnesis.app/new` - Navigate to new operation screen
- `https://mnesis.app/operation` - Navigate to operation list screen
- `https://mnesis.app/admin` - Navigate to admin screen

## Apple App Site Association (AASA) File

The AASA file must be hosted at `https://mnesis.app/.well-known/apple-app-site-association` for Universal Links to work. A template is provided at `deployment/apple-app-site-association.template`.

### AASA File Setup

1. **Replace TEAM_ID**: Update the template with your Apple Developer Team ID
   - Find your Team ID in the Apple Developer portal
   - Replace all instances of `TEAM_ID` with your actual 10-character Team ID

2. **Host the file**: Upload the AASA file to your web server at:
   ```
   https://mnesis.app/.well-known/apple-app-site-association
   ```

3. **Content-Type**: Ensure the file is served with the correct MIME type:
   ```
   Content-Type: application/json
   ```

4. **HTTPS Required**: The file MUST be served over HTTPS with a valid SSL certificate

### AASA File Example

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "ABC123DEFG.com.mnesis.mnesis-flutter",
        "paths": [
          "/chat",
          "/new",
          "/operation",
          "/admin"
        ],
        "components": [
          {
            "/": "/*"
          }
        ]
      }
    ]
  },
  "webcredentials": {
    "apps": [ "ABC123DEFG.com.mnesis.mnesis-flutter" ]
  }
}
```

## Testing Deep Links

### Testing Custom URL Scheme

#### iOS Simulator
```bash
# Open chat screen
xcrun simctl openurl booted "mnesis://chat"

# Open new operation screen
xcrun simctl openurl booted "mnesis://new"

# Open operation list
xcrun simctl openurl booted "mnesis://operation"

# Open admin screen
xcrun simctl openurl booted "mnesis://admin"
```

#### Physical Device (via Safari)
1. Open Safari on the iOS device
2. Type the URL in the address bar: `mnesis://chat`
3. Press "Open" when prompted to open in Mnesis

### Testing Universal Links

#### iOS Simulator
```bash
# Open chat screen via Universal Link
xcrun simctl openurl booted "https://mnesis.app/chat"

# Open new operation screen
xcrun simctl openurl booted "https://mnesis.app/new"

# Open operation list
xcrun simctl openurl booted "https://mnesis.app/operation"

# Open admin screen
xcrun simctl openurl booted "https://mnesis.app/admin"
```

#### Physical Device
1. Send yourself a link via Messages, Email, or Notes
2. Tap the link to open the app directly
3. Long-press to see options (Open in Mnesis, Open in Safari)

### Testing with Flutter

```dart
// In your Flutter app, verify deep links are received
import 'package:flutter/services.dart';

// Listen for deep links (handled automatically by go_router)
// The router configuration in app_router.dart will handle navigation
```

## App Store Connect Setup

### 1. Enable Associated Domains

1. Log in to [Apple Developer Portal](https://developer.apple.com)
2. Navigate to Certificates, Identifiers & Profiles
3. Select your App ID
4. Enable "Associated Domains" capability
5. Save changes

### 2. Verify Provisioning Profile

1. Regenerate provisioning profiles after enabling Associated Domains
2. Download and install updated profiles in Xcode
3. Ensure the capability appears in Xcode project settings

### 3. Submit App for Review

When submitting to App Store, ensure:
- Deep linking is tested on real devices
- AASA file is live and accessible
- All deep link paths work correctly

## Troubleshooting

### Common Issues and Solutions

#### 1. Deep links not working

**Issue**: Custom URL scheme not opening the app
- **Solution**: Verify Info.plist configuration is correct
- **Check**: Ensure the app is installed on the device
- **Test**: Try with a different URL scheme to isolate the issue

#### 2. Universal Links not working

**Issue**: HTTPS links open in Safari instead of the app
- **Solution**: Check AASA file is properly hosted
- **Verify**: Use Apple's AASA Validator
- **Test**: `curl -I https://mnesis.app/.well-known/apple-app-site-association`

#### 3. AASA File Validation

Use Apple's validator tool:
```bash
# Check if AASA file is properly formatted
curl https://mnesis.app/.well-known/apple-app-site-association | python -m json.tool
```

#### 4. Entitlements Not Working

**Issue**: Associated domains capability not recognized
- **Solution**: Ensure Runner.entitlements is added to the Xcode project
- **Check**: Verify Team ID is correct in AASA file
- **Fix**: Clean build folder and rebuild

#### 5. Debug Universal Links

Enable debug logging in Xcode:
1. Open Console app on Mac
2. Connect iOS device
3. Filter for "swcd" process
4. Look for messages about domain verification

### Verification Commands

```bash
# Verify AASA file is accessible
curl -v https://mnesis.app/.well-known/apple-app-site-association

# Check SSL certificate
openssl s_client -connect mnesis.app:443 -servername mnesis.app

# Test with Safari on simulator
xcrun simctl openurl booted "https://mnesis.app/chat"
```

## GoRouter Integration

The Flutter app uses GoRouter for navigation, which automatically handles deep links when `FlutterDeepLinkingEnabled` is set to `true` in Info.plist.

### Route Configuration

The routes are defined in `lib/core/router/app_router.dart`:

```dart
final routes = [
  GoRoute(
    name: RoutePaths.chat,
    path: RoutePaths.chat,
    // Handles: mnesis://chat and https://mnesis.app/chat
  ),
  GoRoute(
    name: RoutePaths.newOperation,
    path: RoutePaths.newOperation,
    // Handles: mnesis://new and https://mnesis.app/new
  ),
  // ... other routes
];
```

## Security Considerations

1. **Validate Deep Link Parameters**: Always validate any parameters passed via deep links
2. **Authentication**: Require authentication for sensitive screens
3. **HTTPS Only**: Universal Links require HTTPS with valid SSL
4. **Rate Limiting**: Implement rate limiting for deep link handling
5. **Sanitize Input**: Sanitize any user input from deep link parameters

## Maintenance

### Regular Checks

1. **AASA File**: Verify the file remains accessible after server updates
2. **SSL Certificate**: Ensure SSL certificate doesn't expire
3. **Test Links**: Regularly test all deep link patterns
4. **Monitor Analytics**: Track deep link usage and success rates

### Updating Deep Links

When adding new deep link patterns:
1. Update AASA file with new paths
2. Add corresponding routes in GoRouter
3. Test on both simulator and physical devices
4. Update this documentation

## References

- [Apple Developer - Deep Linking](https://developer.apple.com/documentation/xcode/allowing-apps-and-websites-to-link-to-your-content)
- [Flutter Deep Linking Documentation](https://docs.flutter.dev/development/ui/navigation/deep-linking)
- [Universal Links - Apple Developer](https://developer.apple.com/ios/universal-links/)
- [GoRouter Deep Linking](https://pub.dev/packages/go_router#deep-linking)

## Contact

For issues or questions about deep linking configuration:
- Check the [Flutter GitHub Issues](https://github.com/flutter/flutter/issues)
- Review [go_router documentation](https://pub.dev/packages/go_router)
- Consult Apple Developer Forums for iOS-specific issues