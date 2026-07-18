{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  cpp-utilities,
  kdePackages,
  libid3tag,
  mp4v2,
  pkg-config,
  qt6,
  tagparser,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tageditor";
  version = "3.9.11";

  src = fetchFromGitHub {
    owner = "martchus";
    repo = "tageditor";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5hOflEaBABu2vjrl0bPFhWHK65+yvoXzQAlb8Ealq+o=";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    mp4v2
    libid3tag
    cpp-utilities
    kdePackages.qtutilities
    qt6.qtbase
    qt6.qttools
    qt6.qtwebengine
    tagparser
  ];

  cmakeFlags = [
    "-DQT_PACKAGE_PREFIX=Qt6"
    "-DQt6_DIR=${qt6.qtbase}/lib/cmake/Qt6"
    "-DQt6WebEngineWidgets_DIR=${qt6.qtwebengine}/lib/cmake/Qt6WebEngineWidgets"
  ];

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/Applications
    mv $out/bin/*.app $out/Applications
    ln -s $out/Applications/tageditor.app/Contents/MacOS/tageditor $out/bin/tageditor
  '';

  meta = {
    description = "Tag editor with Qt GUI and command-line interface supporting MP4/M4A/AAC (iTunes), ID3, Vorbis, Opus, FLAC and Matroska";
    homepage = "https://github.com/Martchus/tageditor";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.matthiasbeyer ];
    platforms = lib.platforms.unix;
    mainProgram = "tageditor";
  };
})
