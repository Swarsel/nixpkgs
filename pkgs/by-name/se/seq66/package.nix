{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  autoreconfHook,
  libjack2,
  liblo,
  pkg-config,
  qt5,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "seq66";
  version = "0.99.22";

  src = fetchFromGitHub {
    owner = "ahlstromcj";
    repo = "seq66";
    tag = finalAttrs.version;
    hash = "sha256-KtbMRRxKh+BuYujzh8kqKAbSN8xWUz/ktkCHBnTRaPw=";
  };

  postPatch = ''
    for d in libseq66/src libsessions/include libsessions/src seq_qt5/src seq_rtmidi/src; do
      substituteInPlace "$d/Makefile.am" --replace-fail '$(git_info)' '${finalAttrs.version}'
    done
  '';

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    qt5.qttools
    which
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    alsa-lib
    libjack2
    liblo
    qt5.qtbase
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Loop based midi sequencer with Qt GUI derived from seq24 and sequencer64";
    homepage = "https://github.com/ahlstromcj/seq66";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "qseq66";
  };
})
