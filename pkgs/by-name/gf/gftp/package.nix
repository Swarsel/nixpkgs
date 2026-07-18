{
  lib,
  stdenv,
  fetchFromGitHub,
  gettext,
  gtk3,
  meson,
  ncurses,
  ninja,
  openssl,
  pkg-config,
  readline,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gftp";
  version = "2.9.1b-unstable-2026-03-30";

  src = fetchFromGitHub {
    owner = "masneyb";
    repo = "gftp";
    rev = "f64d27b116be1fc444e0f50ec375847b72df65f7";
    hash = "sha256-2CVRIrSOBi1AUoEKiyYhMmGcIIBnwMQ3EQsgBIvlXEs=";
  };

  nativeBuildInputs = [
    meson
    ninja
    gettext
    pkg-config
  ];

  buildInputs = [
    gtk3
    ncurses
    openssl
    readline
  ];

  hardeningDisable = [ "format" ];

  meta = {
    description = "GTK-based multithreaded FTP client for *nix-based machines";
    homepage = "https://github.com/masneyb/gftp";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.haylin ];
    platforms = lib.platforms.unix;
    mainProgram = "gftp";
  };
})
