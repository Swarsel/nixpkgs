{
  lib,
  stdenv,
  cmake,
  fetchFromBitbucket,
  freetype,
  gtk3,
  libuuid,
  libxkbcommon,
  pkg-config,
  pulseaudio,
  udev,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "deniseemu";
  version = "2.6";

  src = fetchFromBitbucket {
    owner = "piciji";
    repo = "denise";
    rev = "v${finalAttrs.version}";
    hash = "sha256-+PJtYuiZ1eawuVCTo1kqtCmIoBjNKOGRDnbuH3KRpNM=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    udev
    libuuid
    libxkbcommon
    freetype
    pulseaudio
  ];

  meta = {
    description = "C64 / Amiga Emulator";
    homepage = "https://bitbucket.org/piciji/denise";
    license = [ lib.licenses.gpl3Plus ];
    maintainers = [ lib.maintainers.matthewcroughan ];
    platforms = lib.platforms.linux;
    downloadPage = "https://sourceforge.net/projects/deniseemu/";
  };
})
