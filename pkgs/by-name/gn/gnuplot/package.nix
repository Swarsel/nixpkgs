{
  lib,
  stdenv,
  fetchurl,
  cairo,
  coreutils,
  fontconfig,
  gd,
  gnused,
  libcaca,
  libcerf,
  libx11,
  libxaw,
  libxpm,
  libxt,
  lua,
  makeWrapper,
  pango,
  pkg-config,
  qt5,
  readline,
  texinfo,
  texliveSmall,
  wxwidgets_3_2,
  zlib,
  aquaterm ? false,
  withCaca ? false,
  withLua ? false,
  withQt ? false,
  withTeXLive ? false,
  withWxGTK ? false,
}:

let
  withX = !aquaterm && !stdenv.hostPlatform.isDarwin;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "gnuplot";
  version = "6.0.4";

  src = fetchurl {
    url = "mirror://sourceforge/gnuplot/gnuplot-${finalAttrs.version}.tar.gz";
    hash = "sha256-RY2UdpYl5z1fYjJQD0nLrcsrGDOA1D0iZqD5cBrrnFs=";
  };

  postPatch = ''
    # lrelease is in qttools, not in qtbase.
    sed -i configure -e 's|''${QT5LOC}/lrelease|lrelease|'
  '';

  nativeBuildInputs = [
    makeWrapper
    pkg-config
    texinfo
  ]
  ++ lib.optionals withQt [
    qt5.qttools
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    cairo
    gd
    libcerf
    pango
    readline
    zlib
  ]
  ++ lib.optional withTeXLive texliveSmall
  ++ lib.optional withLua lua
  ++ lib.optional withCaca libcaca
  ++ lib.optionals withX [
    libx11
    libxpm
    libxt
    libxaw
  ]
  ++ lib.optionals withQt [
    qt5.qtbase
    qt5.qtsvg
  ]
  ++ lib.optional withWxGTK wxwidgets_3_2;

  configureFlags = [
    (if withX then "--with-x" else "--without-x")
    (if withQt then "--with-qt=qt5" else "--without-qt")
    (if aquaterm then "--with-aquaterm" else "--without-aquaterm")
  ]
  ++ lib.optional withCaca "--with-caca"
  ++ lib.optional withTeXLive "--with-texdir=${placeholder "out"}/share/texmf/tex/latex/gnuplot";

  # When cross-compiling, don't build docs and demos.
  # Inspiration taken from https://sourceforge.net/p/gnuplot/gnuplot-main/merge-requests/10/
  makeFlags = lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    "-C src"
  ];

  env = lib.optionalAttrs (stdenv.hostPlatform.isDarwin && withQt) {
    CXXFLAGS = "-std=c++11";
  };

  # binary wrappers don't support --run
  postInstall = lib.optionalString withX ''
    wrapProgramShell $out/bin/gnuplot \
       --prefix PATH : '${
         lib.makeBinPath [
           gnused
           coreutils
           fontconfig.bin
         ]
       }' \
       "''${gappsWrapperArgs[@]}" \
       "''${qtWrapperArgs[@]}" \
       --run '. ${./set-gdfontpath-from-fontconfig.sh}'
  '';

  # we'll wrap things ourselves
  dontWrapGApps = true;
  dontWrapQtApps = true;
  enableParallelBuilding = true;

  meta = {
    description = "Portable command-line driven graphing utility for many platforms";
    homepage = "http://www.gnuplot.info/";
    license = lib.licenses.gnuplot;
    maintainers = [ ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "gnuplot";
  };
})
