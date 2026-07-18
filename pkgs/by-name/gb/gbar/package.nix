{
  lib,
  stdenv,
  fetchFromGitHub,
  bluez,
  cmake,
  gtk-layer-shell,
  gtk3,
  libdbusmenu-gtk3,
  libpulseaudio,
  libsass,
  meson,
  ninja,
  pkg-config,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:

stdenv.mkDerivation {
  pname = "gbar";
  version = "0-unstable-2024-12-17";

  src = fetchFromGitHub {
    owner = "scorpion-26";
    repo = "gBar";
    rev = "03bedc7471add061fb15e0ca1c9d2f729b8c5d7b";
    hash = "sha256-4OfcG1DcqemLrK5D75S1x25g9K0k2+eEUQUXgYEYBf8=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    meson
    ninja
    cmake
    pkg-config
  ];

  buildInputs = [
    wayland
    wayland-protocols
    wayland-scanner
    bluez
    gtk3
    gtk-layer-shell
    libpulseaudio
    libsass
    libdbusmenu-gtk3
  ];

  meta = {
    description = "Blazingly fast status bar written with GTK";
    homepage = "https://github.com/scorpion-26/gBar";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ocfox ];
    platforms = lib.platforms.linux;
    mainProgram = "gBar";
  };
}
