#!/bin/bash

set -e

echo "📖 Start documentation preview..."
swift package --disable-sandbox preview-documentation --target SNetwork