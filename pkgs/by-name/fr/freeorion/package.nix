{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  boost,
  cmake,
  doxygen,
  freetype,
  glew,
  graphviz,
  libGL,
  libGLU,
  libjpeg,
  libogg,
  libpng,
  libtiff,
  libvorbis,
  libxslt,
  makeWrapper,
  openal,
  python3,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "freeorion";
  version = "0.5.1.2";

  src = fetchFromGitHub {
    owner = "freeorion";
    repo = "freeorion";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/pLNOkxjuh/vdQQZQ9BzPCMygYPMDJDJuSXxn5lJt2o=";
  };

  nativeBuildInputs = [
    cmake
    doxygen
    graphviz
    makeWrapper
  ];

  buildInputs = [
    (boost.override {
      enablePython = true;
      python = python3;
    })
    (python3.withPackages (p: with p; [ pycodestyle ]))
    SDL2
    freetype
    glew
    libGL
    libGLU
    libjpeg
    libogg
    libpng
    libtiff
    libvorbis
    openal
    zlib
  ];

  # as of 0.5.0.1 FreeOrion doesn't work with "-DOpenGL_GL_PREFERENCE=GLVND"
  cmakeFlags = [ "-DOpenGL_GL_PREFERENCE=LEGACY" ];

  postInstall = ''
    mkdir -p $out/libexec
    # We need final slashes for XSLT replace to work properly
    substitute ${./fix-paths.xslt} $out/share/freeorion/fix-paths.xslt \
      --subst-var-by nixStore "$NIX_STORE/" \
      --subst-var-by out "$out/"
    substitute ${./fix-paths.sh} $out/libexec/fix-paths \
      --subst-var-by libxsltBin ${libxslt.bin} \
      --subst-var-by shell ${stdenv.shell} \
      --subst-var out
    chmod +x $out/libexec/fix-paths

    wrapProgram $out/bin/freeorion \
      --run $out/libexec/fix-paths \
      --prefix LD_LIBRARY_PATH : $out/lib/freeorion
  '';

  meta = {
    description = "Free, open source, turn-based space empire and galactic conquest (4X) computer game";
    homepage = "https://www.freeorion.org/";

    license = with lib.licenses; [
      gpl2Only
      cc-by-sa-30
    ];

    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
