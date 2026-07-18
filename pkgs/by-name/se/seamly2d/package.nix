{
  lib,
  stdenv,
  fetchFromGitHub,
  addDriverRunpath,
  fontconfig,
  freetype,
  git,
  libgbm,
  libsForQt5,
  libxcb,
  libxi,
  libxrender,
  poppler-utils,
  python3,
  xvfb-run,
}:
let
  qtPython = python3.withPackages (pkgs: with pkgs; [ pyqt5 ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "seamly2d";
  version = "2025.8.4.217";

  src = fetchFromGitHub {
    owner = "FashionFreedom";
    repo = "Seamly2D";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PaGYpGZJGXPXJdfkS0siXGKxhSSdGCzDxAYdGv/lPvA=";
  };

  postPatch = ''
    substituteInPlace src/app/seamly2d/mainwindowsnogui.cpp \
      --replace-fail 'define PDFTOPS "pdftops"' 'define PDFTOPS "${lib.getBin poppler-utils}/bin/pdftops"'
    substituteInPlace src/libs/vwidgets/export_format_combobox.cpp \
      --replace-fail 'define PDFTOPS "pdftops"' 'define PDFTOPS "${lib.getBin poppler-utils}/bin/pdftops"'
  '';

  nativeBuildInputs = [
    addDriverRunpath
    xvfb-run
    fontconfig
    libsForQt5.wrapQtAppsHook
    libsForQt5.qmake
    libsForQt5.qttools
  ];

  buildInputs = [
    libsForQt5.qtmultimedia
    git
    qtPython
    libsForQt5.qtbase
    poppler-utils
    libsForQt5.qtxmlpatterns
    libsForQt5.qtsvg
    libgbm
    freetype
    libxi
    libxrender
    libxcb
  ];

  postInstall = ''
    mv $out/share/seamly2d/* $out/share/.
    rmdir $out/share/seamly2d

    mkdir -p $out/share/mime/packages
    cp dist/debian/seamly2d.sharedmimeinfo $out/share/mime/packages/seamly2d.xml
  '';

  installFlags = [ "INSTALL_ROOT=$(out)" ];

  qmakeFlags = [
    "PREFIX=/"
    "PREFIX_LIB=/lib"
    "Seamly2D.pro"
    "-r"
    "CONFIG+=noDebugSymbols"
    "CONFIG+=no_ccache"
  ];

  meta = {
    description = "Open source patternmaking software";
    homepage = "https://seamly.net/";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ WhittlesJr ];
    platforms = lib.platforms.linux;
  };
})
