{
  lib,
  stdenv,
  fetchzip,
  fltk,
  libGLU,
  libjpeg,
  libxinerama,
  xdg-utils,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "eureka-editor";
  version = "1.27b";

  src = fetchzip {
    url = "mirror://sourceforge/eureka-editor/Eureka/${lib.versions.majorMinor finalAttrs.version}/eureka-${finalAttrs.version}-source.tar.gz";
    sha256 = "075w7xxsgbgh6dhndc1pfxb2h1s5fhsw28yl1c025gmx9bb4v3bf";
  };

  postPatch = ''
    substituteInPlace src/main.cc --replace /usr/local $out
    substituteInPlace Makefile    --replace /usr/local $out
  '';

  buildInputs = [
    fltk
    zlib
    xdg-utils
    libjpeg
    libxinerama
    libGLU
  ];

  preInstall = ''
    mkdir -p $out/bin $out/share/applications $out/share/icons $out/man/man6
    cp misc/eureka.desktop $out/share/applications
    cp misc/eureka.ico $out/share/icons
    cp misc/eureka.6 $out/man/man6
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Map editor for the classic DOOM games, and a few related games such as Heretic and Hexen";
    homepage = "https://eureka-editor.sourceforge.net";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.all;
    badPlatforms = lib.platforms.darwin;
    mainProgram = "eureka";
  };
})
