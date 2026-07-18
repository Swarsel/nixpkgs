{
  lib,
  stdenv,
  fetchFromGitHub,
  at-spi2-atk,
  at-spi2-core,
  cmake,
  doxygen,
  fetchpatch,
  gtk3,
  libdatrie,
  libepoxy,
  libsForQt5,
  libselinux,
  libsepol,
  libthai,
  libxdmcp,
  libxtst,
  pkg-config,
  util-linux,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:

stdenv.mkDerivation {
  pname = "maliit-framework";
  version = "2.3.0-unstable-2024-06-24";

  src = fetchFromGitHub {
    owner = "maliit";
    repo = "framework";
    rev = "ba6f7eda338a913f2c339eada3f0382e04f7dd67";
    hash = "sha256-iwWLnstQMG8F6uE5rKF6t2X43sXQuR/rIho2RN/D9jE=";
  };

  nativeBuildInputs = [
    cmake
    doxygen
    pkg-config
    wayland-protocols
    wayland-scanner
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    at-spi2-atk
    at-spi2-core
    libepoxy
    gtk3
    libdatrie
    libselinux
    libsepol
    libthai
    util-linux
    wayland
    libxdmcp
    libxtst
  ];

  cmakeFlags = [
    "-DQT5_PLUGINS_INSTALL_DIR=${placeholder "out"}/${libsForQt5.qtbase.qtPluginPrefix}"
  ];

  meta = {
    description = "Core libraries of Maliit and server";
    homepage = "http://maliit.github.io/";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
    mainProgram = "maliit-server";
  };
}
