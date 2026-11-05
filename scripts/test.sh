#!/bin/zsh
set -eu
cd "${0:A:h}/.."
mkdir -p build/tests
xcrun swiftc -swift-version 5 Sources/Core.swift Tests/main.swift -o build/tests/core-tests
build/tests/core-tests
