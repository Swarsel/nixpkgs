{
  lib,
  emptyFile,
  pkgsStatic,
  requireFile,
}:
let
  name = "this-is-a-test";
  requireFileTest =
    requireFile:
    requireFile {
      inherit name;
      hash = lib.fakeHash;
      url = "this-is-a-test";
    };
  requireFile-native = requireFileTest requireFile;
  requireFile-static = requireFileTest pkgsStatic.requireFile;
in
assert lib.assertMsg (
  requireFile-native.name == name && requireFile-static.name == name
) "requireFile derivation name must be the same across different package sets";
emptyFile
