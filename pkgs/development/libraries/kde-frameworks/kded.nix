{
  lib,
  cmake,
  extra-cmake-modules,
  gsettings-desktop-schemas,
  kconfig,
  kcoreaddons,
  kcrash,
  kdbusaddons,
  kdoctools,
  kservice,
  mkDerivation,
  propagate,
  qtbase,
  wrapGAppsHook3,
}:

mkDerivation {
  pname = "kded";

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    kdoctools
    wrapGAppsHook3
  ];

  buildInputs = [
    gsettings-desktop-schemas
    kconfig
    kcoreaddons
    kcrash
    kdbusaddons
    kservice
    qtbase
  ];

  preFixup = ''
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dontWrapGApps = true;
  setupHook = propagate "out";
  meta.platforms = lib.platforms.linux ++ lib.platforms.freebsd;
}
