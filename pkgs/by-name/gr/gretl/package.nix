{
  lib,
  stdenv,
  fetchurl,
  curl,
  fftw,
  gmp,
  gnuplot,
  gtk3,
  gtksourceview3,
  json-glib,
  lapack,
  libxml2,
  llvmPackages,
  mpfr,
  openblas,
  pkg-config,
  readline,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gretl";
  version = "2026a";

  src = fetchurl {
    url = "mirror://sourceforge/gretl/gretl-${finalAttrs.version}.tar.xz";
    hash = "sha256-F5aV3rkZOe2g9aQBCuhUrep4O2idpVkAVtoFzuq9r2Q=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    curl
    fftw
    gmp
    gnuplot
    gtk3
    gtksourceview3
    json-glib
    lapack
    libxml2
    mpfr
    openblas
    readline
  ]
  ++ lib.optionals stdenv.cc.isClang [ llvmPackages.openmp ];

  env.NIX_LDFLAGS = lib.optionalString stdenv.cc.isClang "-lomp";
  enableParallelBuilding = true;
  # Missing install depends:
  #  cp: cannot stat '...-gretl-2022c/share/gretl/data/plotbars': Not a directory
  #  make[1]: *** [Makefile:73: install_datafiles] Error 1
  enableParallelInstalling = false;

  meta = {
    description = "Software package for econometric analysis";

    longDescription = ''
      gretl is a cross-platform software package for econometric analysis,
      written in the C programming language.
    '';

    homepage = "https://gretl.sourceforge.net";
    license = lib.licenses.gpl3;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})
