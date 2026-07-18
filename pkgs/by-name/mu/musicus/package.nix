{
  lib,
  stdenv,
  fetchFromGitHub,
  blueprint-compiler,
  cargo,
  dbus,
  desktop-file-utils,
  glib,
  gst_all_1,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  rustc,
  sqlite,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "musicus";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "johrpan";
    repo = "musicus";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6+JcgseNgHN7q6v0+gcDmZKA7wr52QVG1lncxNynORU=";
  };

  nativeBuildInputs = [
    meson
    ninja
    blueprint-compiler
    wrapGAppsHook4
    rustPlatform.cargoSetupHook
    cargo
    rustc
    desktop-file-utils
    pkg-config
  ];

  buildInputs = [
    glib
    libadwaita
    dbus
    openssl
    sqlite
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-PWqt5G+OjijyAoSj61iUjWBT6bV5d54okF/vm0+hWsA=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Classical music player and organizer";
    homepage = "https://github.com/johrpan/musicus";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "musicus";
  };
})
