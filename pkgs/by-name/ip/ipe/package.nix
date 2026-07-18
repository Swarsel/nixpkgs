{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  cairo,
  copyDesktopItems,
  freetype,
  ghostscriptX,
  gsl,
  libjpeg,
  libpng,
  libspiro,
  lua5,
  makeDesktopItem,
  pkg-config,
  qhull,
  qt6Packages,
  texliveSmall,
  zlib,
  withQVoronoi ? false,
  withTeXLive ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ipe";
  version = "7.2.30";

  src = fetchFromGitHub {
    owner = "otfried";
    repo = "ipe";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bvwEgEP/cinigixJr8e964sm6secSK+7Ul7WFfwM0gE=";
  };

  nativeBuildInputs = [
    pkg-config
    copyDesktopItems
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    cairo
    freetype
    ghostscriptX
    gsl
    libjpeg
    libpng
    libspiro
    lua5
  ]
  ++ (with qt6Packages; [
    qtbase
    qtsvg
    zlib
  ])
  ++ (lib.optionals withTeXLive [
    texliveSmall
  ])
  ++ (lib.optionals withQVoronoi [
    qhull
  ]);

  makeFlags = [
    "-C src"
    "IPEPREFIX=${placeholder "out"}"
    "LUA_PACKAGE=lua"
    "MOC=${buildPackages.qt6Packages.qtbase}/libexec/moc"
    "IPE_NO_SPELLCHECK=1" # qtSpell is not yet packaged
  ]
  ++ (lib.optionals withQVoronoi [
    "IPEQVORONOI=1"
    "QHULL_CFLAGS=-I${qhull}/include/libqhull_r"
  ]);

  postInstall = ''
    mkdir -p $out/share/icons/hicolor/128x128/apps
    ln -s $out/share/ipe/${finalAttrs.version}/icons/icon_128x128.png $out/share/icons/hicolor/128x128/apps/ipe.png
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Graphics"
        "Qt"
      ];

      comment = "A drawing editor for creating figures in PDF format";
      desktopName = "Ipe";
      exec = "ipe";
      genericName = "Drawing editor";
      icon = "ipe";

      mimeTypes = [
        "text/xml"
        "application/pdf"
      ];

      name = "ipe";
      startupNotify = true;
      startupWMClass = "ipe";
    })
  ];

  enableParallelBuilding = true;
  qtWrapperArgs = lib.optionals withTeXLive [ "--prefix PATH : ${lib.makeBinPath [ texliveSmall ]}" ];

  meta = {
    description = "Editor for drawing figures";

    longDescription = ''
      Ipe is an extensible drawing editor for creating figures in PDF and Postscript format.
      It supports making small figures for inclusion into LaTeX-documents
      as well as presentations in PDF.
    '';

    homepage = "http://ipe.otfried.org"; # https not available
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
