# Package

version = "0.1.0"
author = "fox0430"
description = "Nim bindings for PoDoFo library"
license = "MIT"
installDirs = @["lowlevel"]
backend = "cpp"

# Dependencies

requires "nim >= 2.0.6"

# Tasks

task test, "Run tests":
  exec "nim cpp tests/test_basic.nim"
  exec "nim cpp tests/test_raw.nim"
