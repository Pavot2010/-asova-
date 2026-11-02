#!/usr/bin/env sh
set -eu
APP_HOME=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
GRADLE_VERSION=8.9
GRADLE_HOME="$HOME/.gradle/casovac/gradle-$GRADLE_VERSION"
if [ ! -x "$GRADLE_HOME/bin/gradle" ]; then
    mkdir -p "$HOME/.gradle/casovac"
    TMP_DIR=$(mktemp -d)
    trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM
    echo "Stahuji Gradle $GRADLE_VERSION..."
    curl -fL "https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip" -o "$TMP_DIR/gradle.zip"
    unzip -q "$TMP_DIR/gradle.zip" -d "$TMP_DIR"
    rm -rf "$GRADLE_HOME"
    mv "$TMP_DIR/gradle-$GRADLE_VERSION" "$GRADLE_HOME"
fi
exec "$GRADLE_HOME/bin/gradle" -p "$APP_HOME" "$@"
