{
  lib,
  stdenv,
  fetchurl,
  gfortran,
  llvmPackages,
  mpi,
  perl,
  testers,
  enableMpi ? false,
  precision ? "double",
  withDoc ? stdenv.cc.isGNU,
}:

assert lib.elem precision [
  "single"
  "double"
  "long-double"
  "quad-precision"
];

stdenv.mkDerivation (finalAttrs: {
  pname = "fftw-${precision}";
  version = "3.3.11";

  src = fetchurl {
    hash = "sha256-VjDCTN6zOxMWEvfrSxqZNCNHVPnziP+GF0WNC+byOaE=";

    urls = [
      "https://fftw.org/fftw-${finalAttrs.version}.tar.gz"
      "ftp://ftp.fftw.org/pub/fftw/fftw-${finalAttrs.version}.tar.gz"
    ];
  };

  outputs = [
    "out"
    "dev"
    "man"
  ]
  ++ lib.optional withDoc "info"; # it's dev-doc only

  # fftw builds with -mtune=native by default
  postPatch = ''
    substituteInPlace configure --replace-fail "-mtune=native" "-mtune=generic"
  '';

  strictDeps = true;
  nativeBuildInputs = [ gfortran ];

  buildInputs =
    lib.optionals stdenv.cc.isClang [
      # TODO: This may mismatch the LLVM version sin the stdenv, see #79818.
      llvmPackages.openmp
    ]
    ++ lib.optional enableMpi mpi;

  configureFlags = [
    "--enable-shared"
    "--enable-threads"
    "--enable-openmp"
  ]

  ++ lib.optional (precision != "double") "--enable-${precision}"
  # https://www.fftw.org/fftw3_doc/SIMD-alignment-and-fftw_005fmalloc.html
  # FFTW will try to detect at runtime whether the CPU supports these extensions
  ++
    lib.optionals (stdenv.hostPlatform.isx86_64 && (precision == "single" || precision == "double"))
      [
        "--enable-sse2"
        "--enable-avx"
        "--enable-avx2"
        "--enable-avx512"
        "--enable-avx128-fma"
      ]
  ++
    lib.optionals (stdenv.hostPlatform.isAarch64 && (precision == "single" || precision == "double"))
      [
        "--enable-neon"
      ]
  ++ lib.optionals enableMpi [
    "--enable-mpi"
    # link libfftw3_mpi explicitly with -lmpi
    # linker on darwin requires all symbols to be resolvable at link time
    # see
    #   https://github.com/FFTW/fftw3/issues/274
    #   https://github.com/spack/spack/pull/29279
    "MPILIBS=-lmpi"
  ]
  # doc generation causes Fortran wrapper generation which hard-codes gcc
  ++ lib.optional (!withDoc) "--disable-doc";

  nativeCheckInputs = [ perl ];
  __structuredAttrs = true;
  enableParallelBuilding = true;
  outputBin = "dev"; # fftw-wisdom
  passthru.tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

  meta = {
    description = "Fastest Fourier Transform in the West library";
    homepage = "https://www.fftw.org/";
    changelog = "https://github.com/FFTW/fftw3/blob/fftw-${finalAttrs.version}/NEWS";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    # quad-precision requires libquadmath from gfortran, but libquadmath is not supported on aarch64
    badPlatforms = lib.optionals (precision == "quad-precision") lib.platforms.aarch64;

    pkgConfigModules = [
      {
        "double" = "fftw3";
        "long-double" = "fftw3l";
        "quad-precision" = "fftw3q";
        "single" = "fftw3f";
      }
      .${precision}
    ];
  };
})
