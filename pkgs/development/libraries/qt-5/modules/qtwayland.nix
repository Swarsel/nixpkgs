{
  lib,
  pkg-config,
  qtModule,
  qtbase,
  qtquickcontrols,
  wayland,
  wayland-scanner,
}:

qtModule {
  pname = "qtwayland";

  outputs = [
    "out"
    "dev"
    "bin"
  ];

  patches = [
    # NixOS-specific, ensure that app_id is correctly determined for
    # wrapped executables from `wrapQtAppsHook` (see comment in patch for further
    # context).
    ./qtwayland-app_id.patch
  ];

  nativeBuildInputs = [
    pkg-config
    wayland-scanner
  ];

  buildInputs = [ wayland ];

  propagatedBuildInputs = [
    qtbase
    qtquickcontrols
  ];

  meta.badPlatforms = lib.platforms.darwin;
}
