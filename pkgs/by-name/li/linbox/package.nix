{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  blas,
  fflas-ffpack,
  givaro,
  gmpxx,
  lapack,
  pkg-config,
}:

assert (!blas.isILP64) && (!lapack.isILP64);

stdenv.mkDerivation (finalAttrs: {
  pname = "linbox";
  version = "1.7.1";

  src = fetchFromGitHub {
    owner = "linbox-team";
    repo = "linbox";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-WUSQI9svxbrDTtWBjCF2XMhRFdKwCht8XBmJIJ3DR1E=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    givaro
    blas
    gmpxx
    fflas-ffpack
  ];

  configureFlags = [
    "--with-blas-libs=-lblas"
    "--without-archnative"
  ]
  ++ lib.optionals stdenv.hostPlatform.isx86_64 [
    # disable SIMD instructions (which are enabled *when available* by default)
    "--${if stdenv.hostPlatform.sse3Support then "enable" else "disable"}-sse3"
    "--${if stdenv.hostPlatform.ssse3Support then "enable" else "disable"}-ssse3"
    "--${if stdenv.hostPlatform.sse4_1Support then "enable" else "disable"}-sse41"
    "--${if stdenv.hostPlatform.sse4_2Support then "enable" else "disable"}-sse42"
    "--${if stdenv.hostPlatform.avxSupport then "enable" else "disable"}-avx"
    "--${if stdenv.hostPlatform.avx2Support then "enable" else "disable"}-avx2"
    "--${if stdenv.hostPlatform.fmaSupport then "enable" else "disable"}-fma"
    "--${if stdenv.hostPlatform.fma4Support then "enable" else "disable"}-fma4"
  ];

  doCheck = true;
  enableParallelBuilding = true;
  # https://github.com/linbox-team/linbox/issues/304
  hardeningDisable = [ "fortify3" ];

  meta = {
    description = "C++ library for exact, high-performance linear algebra";
    homepage = "https://linalg.org/";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.unix;
    mainProgram = "linbox-config";
    teams = [ lib.teams.sage ];
  };
})
