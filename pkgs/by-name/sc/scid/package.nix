{
  lib,
  stdenv,
  fetchFromGitHub,
  libx11,
  makeWrapper,
  tcl,
  tk,
  zlib,
}:

tcl.mkTclDerivation rec {
  pname = "scid";
  version = "5.0.2";

  src = fetchFromGitHub {
    owner = "benini";
    repo = "scid";
    rev = "v${version}";
    hash = "sha256-5WGZm7EwhZAMKJKxj/OOIFOJIgPBcc6/Bh4xVAlia4Y=";
  };

  postPatch = ''
    substituteInPlace configure \
      --replace "set var(INSTALL) {install_mac}" ""
  '';

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    tk
    libx11
    zlib
  ];

  configureFlags = [
    "BINDIR=$(out)/bin"
    "SHAREDIR=$(out)/share"
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
  ];

  addTclConfigureFlags = false;
  enableParallelBuilding = true;

  meta = {
    description = "Chess database with play and training functionality";
    homepage = "https://scid.sourceforge.net/";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ agbrooks ];
    platforms = lib.platforms.all;
  };
}
