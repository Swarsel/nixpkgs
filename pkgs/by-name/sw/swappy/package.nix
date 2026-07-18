{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  glib,
  gtk3,
  hicolor-icon-theme,
  libnotify,
  meson,
  ninja,
  pango,
  pkg-config,
  scdoc,
  wayland,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "swappy";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "jtheoof";
    repo = "swappy";
    rev = "v${finalAttrs.version}";
    hash = "sha256-rPe567ajk/umfZ2HHm+pRxpbMOTyUmqd+22kwDSFMTc=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    glib
    meson
    ninja
    pkg-config
    scdoc
    wrapGAppsHook3
  ];

  buildInputs = [
    cairo
    pango
    gtk3
    libnotify
    wayland
    glib
    hicolor-icon-theme
  ];

  mesonFlags = [
    # TODO: https://github.com/NixOS/nixpkgs/issues/36468
    "-Dc_args=-I${glib.dev}/include/gio-unix-2.0"
  ];

  meta = {
    description = "Wayland native snapshot editing tool, inspired by Snappy on macOS";
    homepage = "https://github.com/jtheoof/swappy";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.matthiasbeyer ];
    platforms = lib.platforms.linux;
    mainProgram = "swappy";
  };
})
