{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  bison,
  blas,
  bzip2,
  fftw,
  flex,
  gfortran,
  lapack,
  libxml2,
  protobuf_21,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qdng";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "quantum-dynamics-ng";
    repo = "QDng";
    tag = "v${finalAttrs.version}";
    hash = "sha256-T59Bb014KSUOOFTFjPOrWmbF6GqIqAIyrb3Xe5TwU88=";
  };

  nativeBuildInputs = [
    autoreconfHook
    bison
    flex
    gfortran
  ];

  buildInputs = [
    blas
    bzip2
    fftw
    lapack
    libxml2
    protobuf_21
    zlib
  ];

  configureFlags = [
    "--enable-openmp"
    "--disable-gccopt"
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Molecular wavepacket dynamics package";
    homepage = "https://github.com/quantum-dynamics-ng/QDng";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.markuskowa ];
    platforms = lib.platforms.linux;
  };
})
