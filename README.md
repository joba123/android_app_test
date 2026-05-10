# Android App Test

Minimal Android test application. The first screen contains one centered button labeled **Test Button**.

## Build APK locally

This repository intentionally stores only text-based source and project files. Generated binary artifacts such as APKs are ignored and should be built locally or by CI.

In an Android development environment with the Android SDK installed and access to Google's Maven repository, build the debug APK with:

```bash
gradle assembleDebug
```

The generated debug APK is written to:

```text
app/build/outputs/apk/debug/app-debug.apk
```

## SDK-free fallback builder

If the Android SDK is unavailable, the repository also includes a text-only helper script that can generate a minimal debug-signed APK locally:

```bash
python3 scripts/build_manual_apk.py
```

That generated APK is written to:

```text
build/outputs/apk/debug/app-debug.apk
```

Generated APKs, keystores, and build output directories are ignored by Git.
