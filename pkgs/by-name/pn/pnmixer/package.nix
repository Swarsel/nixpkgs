{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  cmake,
  gettext,
  glib,
  gtk3,
  libnotify,
  libx11,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pnmixer";
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "nicklan";
    repo = "pnmixer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-iITliZrWZd0NvFgFzO49c94ry4T9J3jPIq61MZK6JhA=";
  };

  patches = [
    # https://github.com/nicklan/pnmixer/pull/197
    ./fix-cmake-version.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    gettext
  ];

  buildInputs = [
    alsa-lib
    gtk3
    glib
    libnotify
    libx11
  ];

  __structuredAttrs = true;
  enableParallelBuilding = true;

  meta = {
    description = "ALSA volume mixer for the system tray";
    homepage = "https://github.com/nicklan/pnmixer";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      campadrenalin
      romildo
    ];

    platforms = lib.platforms.linux;
    mainProgram = "pnmixer";
  };
})
