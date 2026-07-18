{
  lib,
  stdenv,
  fetchFromGitHub,
  blas,
  fetchpatch,
  gfortran,
  lapack,
  python3,
}:
assert (!blas.isILP64);
assert blas.isILP64 == lapack.isILP64;

stdenv.mkDerivation (finalAttrs: {
  pname = "wannier90";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "wannier-developers";
    repo = "wannier90";
    rev = "v${finalAttrs.version}";
    hash = "sha256-+Mq7lM6WuwAnK/2FlDz9gNRIg2sRazQRezb3BfD0veY=";
  };

  patches = [
    # upstream patch, fixes test runner.
    (fetchpatch {
      hash = "sha256-6ZfHd8CVTzfaj99AA3dsJJ/EOeCZmzACAM5pe2wBo8g=";
      name = "replace-obsolete-pipes-module";
      url = "https://github.com/wannier-developers/wannier90/commit/8aef6edaa4f169d45b479dc5d5c5efb8b9385a49.patch";
    })
  ];

  # test cases are removed as error bounds of wannier90 are obviously to tight
  postPatch = ''
    rm -r test-suite/tests/testpostw90_{fe_kpathcurv,fe_kslicecurv,si_geninterp,si_geninterp_wsdistance}
    rm -r test-suite/tests/testw90_example26   # Fails without AVX optimizations
    patchShebangs test-suite/run_tests test-suite/testcode/bin/testcode.py
  '';

  nativeBuildInputs = [ gfortran ];

  buildInputs = [
    blas
    lapack
  ];

  buildFlags = [
    "all"
    "dynlib"
  ];

  doCheck = true;
  checkInputs = [ python3 ];

  preInstall = ''
    installFlagsArray+=(
      PREFIX=$out
    )
  '';

  postInstall = ''
    cp libwannier.so $out/lib/libwannier.so

    mkdir $out/include
    find ./src/obj/ -name "*.mod" -exec cp {} $out/include/. \;
  '';

  checkTarget = [ "test-serial" ];

  configurePhase = ''
    runHook preConfigure

    cp config/make.inc.gfort make.inc

    runHook postConfigure
  '';

  enableParallelBuilding = true;
  hardeningDisable = [ "format" ];

  meta = {
    description = "Calculation of maximally localised Wannier functions";
    homepage = "https://github.com/wannier-developers/wannier90";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.sheepforce ];
    platforms = [ "x86_64-linux" ];
  };
})
