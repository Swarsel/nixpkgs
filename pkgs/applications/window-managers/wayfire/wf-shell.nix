{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  gtk-layer-shell,
  gtkmm3,
  libdbusmenu-gtk3,
  meson,
  ninja,
  pkg-config,
  pulseaudio,
  wayfire,
  wayland-scanner,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wf-shell";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "WayfireWM";
    repo = "wf-shell";
    rev = "v${finalAttrs.version}";
    hash = "sha256-PLTeFGecxVwU2LdwnDwiWB1OcbaZjJemMpT0pcCFf/w=";
    fetchSubmodules = true;
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    wayfire
    alsa-lib
    gtkmm3
    gtk-layer-shell
    pulseaudio
    libdbusmenu-gtk3
  ];

  mesonFlags = [ "--sysconfdir /etc" ];

  meta = {
    description = "GTK3-based panel for Wayfire";
    homepage = "https://github.com/WayfireWM/wf-shell";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      wucke13
      wineee
    ];

    platforms = lib.platforms.unix;
  };
})
