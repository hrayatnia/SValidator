#!/bin/bash

set -e  # Exit on error

# Detect branch
BRANCH=${TRAVIS_BRANCH:-$(git rev-parse --abbrev-ref HEAD)}

if [[ "$BRANCH" == "main" ]]; then
    BUILD_MODE="release"
else
    BUILD_MODE="debug"
fi

echo "🚀 Building Swift project in '$BUILD_MODE' mode..."
swift build --configuration $BUILD_MODE

echo "✅ Build complete!"
