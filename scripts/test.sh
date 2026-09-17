#!/bin/bash
set -euo pipefail

frameworks="$(xcode-select -p)/Library/Developer/Frameworks"
build="$(swift build --show-bin-path)"
ln -sfn "$frameworks/Testing.framework" "$build/Testing.framework"
ln -sfn "$(xcode-select -p)/Library/Developer/usr/lib/lib_TestingInterop.dylib" "$build/lib_TestingInterop.dylib"
swift test -Xswiftc -F -Xswiftc "$frameworks" -Xlinker -F -Xlinker "$frameworks"
