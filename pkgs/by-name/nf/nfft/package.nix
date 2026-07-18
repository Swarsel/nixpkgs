{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  bash,
  cunit,
  fetchpatch,
  fftw,
  libtool,
  llvmPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nfft";
  version = "3.5.3";

  src = fetchFromGitHub {
    owner = "NFFT";
    repo = "nfft";
    rev = finalAttrs.version;
    hash = "sha256-HR8ME9PVC+RAv1GIgV2vK6eLU8Wk28+rSzbutThBv3w=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-Ynhsyzf8ECVw4eBq50okd0oikiIfOCqFRHivuceg0KU=";
      name = "fix-gcc15.patch";
      url = "https://github.com/NFFT/nfft/commit/b06d01be964be7490aed797468f9722e2de1dbfa.patch";
    })
  ];

  nativeBuildInputs = [
    autoconf
    automake
    cunit
    libtool
    bash
  ];

  buildInputs = lib.optionals stdenv.cc.isClang [ llvmPackages.openmp ];
  propagatedBuildInputs = [ fftw ];

  configureFlags = [
    "--enable-all"
    "--enable-openmp"
    "--enable-portable-binary"
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";

  preConfigure = ''
    bash bootstrap.sh
  '';

  doCheck = true;
  enableParallelBuilding = true;

  meta = {
    description = "Nonequispaced fast Fourier transform";
    homepage = "https://www-user.tu-chemnitz.de/~potts/nfft/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ hmenke ];
  };
})
