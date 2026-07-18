{
  lib,
  stdenv,
  appstream,
  nixosTests,
  qtbase,
  qttools,
}:

# TODO: look into using the libraries from the regular appstream derivation as we keep duplicates here

stdenv.mkDerivation {
  inherit (appstream) version src;
  pname = "appstream-qt";

  outputs = [
    "out"
    "dev"
    "installedTests"
  ];

  patches = appstream.patches;
  nativeBuildInputs = appstream.nativeBuildInputs ++ [ qttools ];

  buildInputs = appstream.buildInputs ++ [
    appstream
    qtbase
  ];

  mesonFlags = appstream.mesonFlags ++ [
    (lib.mesonBool "qt" true)
  ];

  # AppStreamQt tries to be relocatable, in hacky cmake ways that generally fail
  # horribly on NixOS. Just hardcode the paths.
  postFixup = ''
    sed -i "$dev/lib/cmake/AppStreamQt/AppStreamQtConfig.cmake" \
      -e "/INTERFACE_INCLUDE_DIRECTORIES/ s@\''${PACKAGE_PREFIX_DIR}@$dev@"
    sed -i "$dev/lib/cmake/AppStreamQt/AppStreamQtConfig.cmake" \
      -e "/IMPORTED_LOCATION/ s@\''${PACKAGE_PREFIX_DIR}@$out@"
  '';

  dontWrapQtApps = true;

  passthru = appstream.passthru // {
    tests = {
      installed-tests = nixosTests.installed-tests.appstream-qt;
    };
  };

  meta = appstream.meta // {
    description = "Software metadata handling library - Qt";
  };
}
