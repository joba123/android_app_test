# Android App Test

Minimal Android test application. The app intentionally shows an empty white screen.

## Build APK in GitHub

The GitHub Actions workflow `Build APK` builds the debug APK on every push, pull request, and manual workflow dispatch. On push and manual runs, it also uploads the generated APK directly to Appetize.io. Pull request runs skip the Appetize.io upload so that tokens are not exposed to untrusted PR workflows.

For Appetize.io uploads, configure these repository secrets or variables:

- `APPETIZE_API_TOKEN` (required): Appetize API token used for `X-API-KEY` authentication. If this is missing, the workflow now fails instead of reporting a green run that did not upload anything.
- `APPETIZE_PUBLIC_KEY` (optional): Existing Appetize app public key. Set this after the first successful upload when you want future workflow runs to update the same Appetize app instead of creating a new one.

After a successful upload, open the workflow run summary and use the printed Appetize.io link. If `APPETIZE_PUBLIC_KEY` is not configured, each run creates a new Appetize app and prints the public key that you can save for future updates.

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
