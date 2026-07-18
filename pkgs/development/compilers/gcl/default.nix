{
  lib,
  stdenv,
  fetchurl,
  binutils,
  emacs,
  gmp,
  libx11,
  libxaw,
  libxext,
  libxi,
  libxmu,
  libxt,
  m4,
  mpfr,
  texinfo,
  which,
  xorgproto,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "gcl";
  version = "2.6.14";

  src = fetchurl {
    url = "mirror://gnu/gcl/gcl-${version}.tar.gz";
    hash = "sha256-CfNBfFEqoXM6Y4gJ06Y6wpDuuUSL6CeV9bZoG9MHNFo=";
  };

  buildInputs = [
    mpfr
    m4
    binutils
    emacs
    gmp
    libx11
    xorgproto
    libxi
    libxext
    libxt
    libxaw
    libxmu
    zlib
    which
    texinfo
  ];

  configureFlags = [
    "--enable-ansi"
  ];

  meta = {
    description = "GNU Common Lisp compiler working via GCC";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
    mainProgram = "gcl";
    broken = true; # 2025-01-21; to check after 2.7.0 is tagged
    teams = [ lib.teams.lisp ];
  };
}
