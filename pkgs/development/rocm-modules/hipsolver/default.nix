{
  lib,
  stdenv,
  fetchFromGitHub,
  clr,
  cmake,
  gfortran,
  gtest,
  lapack-reference,
  rocblas,
  rocm-cmake,
  rocmUpdateScript,
  rocsolver,
  rocsparse,
  suitesparse,
  buildBenchmarks ? false,
  buildSamples ? false,
  buildTests ? false,
}:

# Can also use cuSOLVER
stdenv.mkDerivation (finalAttrs: {
  pname = "hipsolver";
  version = "7.2.3";

  src = fetchFromGitHub {
    owner = "ROCm";
    repo = "rocm-libraries";
    rev = "rocm-${finalAttrs.version}";
    hash = "sha256-ts5wuXHoBFZ1WMAk8Ir5cucP75G0SMOWmn3FEH04ZEQ=";

    sparseCheckout = [
      "projects/hipsolver"
      "shared"
    ];
  };

  outputs = [
    "out"
  ]
  ++ lib.optionals buildTests [
    "test"
  ]
  ++ lib.optionals buildBenchmarks [
    "benchmark"
  ]
  ++ lib.optionals buildSamples [
    "sample"
  ];

  nativeBuildInputs = [
    cmake
    rocm-cmake
    clr
    gfortran
  ];

  buildInputs = [
    rocblas
    rocsolver
    rocsparse
    suitesparse
  ]
  ++ lib.optionals buildTests [
    gtest
  ]
  ++ lib.optionals (buildTests || buildBenchmarks) [
    lapack-reference
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_COMPILER=hipcc"
    # Manually define CMAKE_INSTALL_<DIR>
    # See: https://github.com/NixOS/nixpkgs/pull/197838
    "-DCMAKE_INSTALL_BINDIR=bin"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-DBUILD_WITH_SPARSE=OFF" # FIXME: broken - can't find suitesparse/cholmod, looks fixed in master
  ]
  ++ lib.optionals buildTests [
    "-DBUILD_CLIENTS_TESTS=ON"
  ]
  ++ lib.optionals buildBenchmarks [
    "-DBUILD_CLIENTS_BENCHMARKS=ON"
  ]
  ++ lib.optionals buildSamples [
    "-DBUILD_CLIENTS_SAMPLES=ON"
  ];

  postInstall =
    lib.optionalString buildTests ''
      mkdir -p $test/bin
      mv $out/bin/hipsolver-test $test/bin
    ''
    + lib.optionalString buildBenchmarks ''
      mkdir -p $benchmark/bin
      mv $out/bin/hipsolver-bench $benchmark/bin
    ''
    + lib.optionalString buildSamples ''
      mkdir -p $sample/bin
      mv clients/staging/example-* $sample/bin
      patchelf $sample/bin/example-* --shrink-rpath --allowed-rpath-prefixes "$NIX_STORE"
    ''
    + lib.optionalString (buildTests || buildBenchmarks) ''
      rmdir $out/bin
    '';

  sourceRoot = "${finalAttrs.src.name}/projects/hipsolver";
  passthru.updateScript = rocmUpdateScript { inherit finalAttrs; };

  meta = {
    description = "ROCm SOLVER marshalling library";
    homepage = "https://github.com/ROCm/rocm-libraries/tree/develop/projects/hipsolver";
    license = with lib.licenses; [ mit ];
    platforms = lib.platforms.linux;
    teams = [ lib.teams.rocm ];
  };
})
