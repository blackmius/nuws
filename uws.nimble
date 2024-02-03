# Package

version       = "0.1.0"
author        = "dterlyakhin"
description   = "uWebSocket bindings"
license       = "MIT"
srcDir        = "src"

# Dependencies

requires "nim >= 2.0.0"

before install:
  exec "git clone --recurse-submodules --branch v20.58.0 https://github.com/uNetworking/uWebSockets.git src/uWebSockets"
task build_capi, "build capi dependency":
  exec "cd $projectDir/src/uWebSockets/capi && make shared"

