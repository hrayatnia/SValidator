#!/bin/bash
set -e

echo "🔍 Fetching latest tag..."
LATEST_TAG=$(git describe --tags --abbrev=0 || echo "0.0.0")

IFS='.' read -r major minor patch <<< "$LATEST_TAG"
NEW_VERSION="$major.$minor.$((patch + 1))"

echo "📌 New version: $NEW_VERSION"

echo "🔄 Updating Package.swift..."
sed -i '' "s/let version = \".*\"/let version = \"$NEW_VERSION\"/" Package.swift

echo "✅ Version updated: $NEW_VERSION"
echo "NEW_VERSION=$NEW_VERSION" >> $GITHUB_ENV
