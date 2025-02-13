#!/bin/bash
set -e

echo "📖 Generating documentation..."
mkdir -p ./docs  # Ensure the directory exists
swift package --allow-writing-to-directory ./docs \
    generate-documentation --target SNetwork --output-path ./docs \
    --transform-for-static-hosting --hosting-base-path SNetwork

echo "🔍 Checking generated docs:"
ls -la ./docs