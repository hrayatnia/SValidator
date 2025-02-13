#!/bin/bash

set -e

echo "🧪 Running Swift tests with code coverage enabled..."
swift test --parallel --enable-code-coverage

echo "✅ Tests completed successfully!"
