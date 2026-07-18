{
  lib,
  stdenv,
  fetchFromGitHub,
  blas,
  lapack,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "plink-ng";
  version = "1.90b3";

  src = fetchFromGitHub {
    owner = "chrchang";
    repo = "plink-ng";
    rev = "v${finalAttrs.version}";
    sha256 = "1zhffjbwpd50dxywccbnv1rxy9njwz73l4awc5j7i28rgj3davcq";
  };

  buildInputs = [
    zlib
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    blas
    lapack
  ];

  preBuild = ''
    sed -i 's|zlib-1.2.8/zlib.h|zlib.h|g' *.c *.h
    ${lib.optionalString stdenv.cc.isClang "sed -i 's|g++|clang++|g' Makefile.std"}

    makeFlagsArray+=(
      ZLIB=-lz
      BLASFLAGS="-lblas -lcblas -llapack"
    );
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp plink $out/bin
  '';

  makefile = "Makefile.std";

  meta = {
    description = "Comprehensive update to the PLINK association analysis toolset";
    homepage = "https://www.cog-genomics.org/plink2";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
    mainProgram = "plink";
    broken = (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64);
  };
})
