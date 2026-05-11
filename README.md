# Android App Test

Minimal Android test application. The app intentionally shows an empty white screen.

## Build APK in GitHub

The GitHub Actions workflow `Build APK` builds the debug APK on every push, pull request, and manual workflow dispatch. On push and manual runs, it also uploads the generated APK directly to Appetize.io when `APPETIZE_API_TOKEN` is configured as a repository secret or variable. Pull request runs skip the Appetize.io upload so that tokens are not exposed to untrusted PR workflows.

To download the APK:

1. Open the repository on GitHub.
2. Go to **Actions**.
3. Select the latest **Build APK** run.
4. Download the `android-app-test-debug-apk` artifact.

## Local build

```bash
gradle assembleDebug
```

The generated APK is written to `app/build/outputs/apk/debug/app-debug.apk`.
