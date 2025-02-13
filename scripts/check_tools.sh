#!/bin/bash

set -e  # Exit on error

echo "🔍 Checking for required tools..."


check_tool() {
    if ! command -v "$1" &> /dev/null; then
        echo "❌ '$1' is not installed."
        install_tool "$1"
    else
        echo "✅ '$1' is installed."
    fi
}

install_tool() {
    case "$1" in
        llvm-cov|xcrun\ llvm-cov)
            if [[ "$OSTYPE" == "darwin"* ]]; then
                echo "🛠 Installing llvm-cov via Xcode..."
                xcode-select --install
            else
                echo "❌ Please install llvm-cov manually for your system."
                exit 1
            fi
            ;;
        curl)
            echo "🛠 Installing curl..."
            brew install curl || sudo apt-get install -y curl
            ;;
        bash)
            echo "🛠 Installing bash..."
            brew install bash || sudo apt-get install -y bash
            ;;
        *)
            echo "⚠️ Please install '$1' manually."
            exit 1
            ;;
    esac
}

LLVM_COV_CMD="llvm-cov"
if [[ "$OSTYPE" == "darwin"* ]]; then
    LLVM_COV_CMD="xcrun llvm-cov"
fi

# Check & Install Required Tools
check_tool swift
check_tool curl
check_tool bash
check_tool "$(echo "$LLVM_COV_CMD" | awk '{print $1}')"

echo "✅ All required tools are installed!"
