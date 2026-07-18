{
  lib,
  stdenv,
  fetchFromGitHub,
  gtk3,
  gtkmm3,
  libevdev,
  libxkbcommon,
  libxml2,
  meson,
  ninja,
  pkg-config,
  wayfire,
  wayland-protocols,
  wayland-scanner,
  wf-shell,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wcm";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "WayfireWM";
    repo = "wcm";
    rev = "v${finalAttrs.version}";
    hash = "sha256-O4BYwb+GOMZIn3I2B/WMJ5tUZlaegvwBuyNK9l/gxvQ=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wayland-scanner
    wrapGAppsHook3
  ];

  buildInputs = [
    wayfire
    wf-shell
    wayland-protocols
    gtk3
    gtkmm3
    libevdev
    libxml2
    libxkbcommon
  ];

  meta = {
    description = "Wayfire Config Manager";
    homepage = "https://github.com/WayfireWM/wcm";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      teatwig
      wucke13
      wineee
    ];

    platforms = lib.platforms.unix;
    mainProgram = "wcm";
  };
})
