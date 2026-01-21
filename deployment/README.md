# Deployment Configuration

## Android App Links Setup

To enable verified HTTPS deep links (App Links) for Android, you need to deploy the `assetlinks.json` file to your server.

### Steps to Configure App Links:

1. **Get your app's SHA256 certificate fingerprint:**

   For debug builds:
   ```bash
   keytool -list -v \
     -keystore ~/.android/debug.keystore \
     -alias androiddebugkey \
     -storepass android \
     -keypass android | grep SHA256
   ```

   For release builds:
   ```bash
   keytool -list -v \
     -keystore path/to/your-release-key.keystore \
     -alias your-key-alias | grep SHA256
   ```

2. **Update the assetlinks.json file:**

   Copy `assetlinks.json.template` to `assetlinks.json` and replace the placeholder fingerprints with your actual SHA256 fingerprints.

3. **Deploy to your server:**

   The file must be accessible at:
   ```
   https://mnesis.app/.well-known/assetlinks.json
   ```

   Requirements:
   - Must be served over HTTPS
   - Must be publicly accessible (no authentication)
   - Content-Type should be `application/json`
   - No redirects allowed

4. **Verify deployment:**

   Test that the file is accessible:
   ```bash
   curl https://mnesis.app/.well-known/assetlinks.json
   ```

   Verify with Google's Digital Asset Links API:
   ```bash
   curl "https://digitalassetlinks.googleapis.com/v1/statements:list?source.web.site=https://mnesis.app&relation=delegate_permission/common.handle_all_urls"
   ```

5. **Test on device:**

   After deploying assetlinks.json, install the app and test:
   ```bash
   # Force re-verification (Android 12+)
   adb shell pm verify-app-links --re-verify com.mnesis.mnesis_flutter

   # Check verification status
   adb shell pm get-app-links com.mnesis.mnesis_flutter
   ```

### Troubleshooting

If App Links are not working:

1. Ensure the SHA256 fingerprint matches your app's signing certificate
2. Check that assetlinks.json is accessible without authentication
3. Verify no typos in package name: `com.mnesis.mnesis_flutter`
4. Clear app data and reinstall after updating assetlinks.json
5. On Android 12+, manually trigger verification with the commands above

### Multiple Environments

For staging/production environments, you can include multiple fingerprints in the same assetlinks.json file:

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.mnesis.mnesis_flutter",
      "sha256_cert_fingerprints": [
        "DEBUG_SHA256_FINGERPRINT",
        "STAGING_SHA256_FINGERPRINT",
        "PRODUCTION_SHA256_FINGERPRINT"
      ]
    }
  }
]
```