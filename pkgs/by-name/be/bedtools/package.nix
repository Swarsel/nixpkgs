{
  lib,
  stdenv,
  fetchFromGitHub,
  bzip2,
  python3,
  xz,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "bedtools";
  version = "2.31.1";

  src = fetchFromGitHub {
    owner = "arq5x";
    repo = "bedtools2";
    rev = "v${version}";
    sha256 = "sha256-rrk+FSv1bGL0D1lrIOsQu2AT7cw2T4lkDiCnzil5fpg=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    python3
  ];

  buildInputs = [
    zlib
    bzip2
    xz
  ];

  buildPhase = "make prefix=$out SHELL=${stdenv.shell} CXX=${cxx} CC=${cc} -j $NIX_BUILD_CORES";
  installPhase = "make prefix=$out SHELL=${stdenv.shell} CXX=${cxx} CC=${cc} install";
  cc = if stdenv.cc.isClang then "clang" else "gcc";
  cxx = if stdenv.cc.isClang then "clang++" else "g++";

  meta = {
    description = "Powerful toolset for genome arithmetic";
    homepage = "https://bedtools.readthedocs.io/en/latest/";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ jbedo ];
    platforms = lib.platforms.unix;
  };
}
