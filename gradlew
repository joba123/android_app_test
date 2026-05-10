#!/usr/bin/env sh
set -eu

if command -v gradle >/dev/null 2>&1; then
    exec gradle "$@"
fi

echo "Gradle is not installed. Install Gradle or run gradle/actions/setup-gradle before using ./gradlew." >&2
exit 127
