{
  lib,
  stdenv,
  fetchurl,
  blas,
  lapack,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ergoscf";
  version = "3.8.2";

  src = fetchurl {
    url = "https://www.ergoscf.org/source/tarfiles/ergo-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-U0NVREEZ8HI0Q0ZcbwvZsYA76PWMh7bqgDG1uaUc01c=";
  };

  patches = [ ./math-constants.patch ];

  postPatch = ''
    patchShebangs ./test
  '';

  buildInputs = [
    blas
    lapack
  ];

  configureFlags = [
    "--enable-linalgebra-templates"
    "--enable-performance"
  ]
  ++ lib.optional stdenv.hostPlatform.isx86_64 "--enable-sse-intrinsics";

  env = {
    LDFLAGS = toString [
      "-lblas"
      "-llapack"
    ];

    # Required for compilation with gcc-14
    NIX_CFLAGS_COMPILE = "-Wno-error=implicit-function-declaration";
  };

  doCheck = true;
  enableParallelBuilding = true;
  # With "fortify3", there are test failures, such as:
  # Testing cnof CAMB3LYP/6-31G using FMM
  # *** buffer overflow detected ***: terminated
  # ./test_fmm_camb3lyp.sh: line 81: 1061289 Aborted                 (core dumped) ./ergo <<EOINPUT > /dev/null
  hardeningDisable = [ "fortify3" ];

  meta = {
    description = "Quantum chemistry program for large-scale self-consistent field calculations";
    homepage = "http://www.ergoscf.org";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.markuskowa ];
    platforms = lib.platforms.linux;
    mainProgram = "ergo";
  };
})
