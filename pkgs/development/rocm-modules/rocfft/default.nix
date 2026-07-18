{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  clr,
  cmake,
  fftw,
  fftwFloat,
  gtest,
  hiprand,
  openmp,
  python3,
  rocm-cmake,
  rocmUpdateScript,
  rocrand,
  sqlite,
  gpuTargets ? clr.localGpuTargets or clr.gpuTargets,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rocfft${clr.gpuArchSuffix}";
  version = "7.2.3";

  src = fetchFromGitHub {
    owner = "ROCm";
    repo = "rocm-libraries";
    rev = "rocm-${finalAttrs.version}";
    hash = "sha256-RjWMzLX0nBA8ClweJ8YgRTn+Nzt/VUkOoSw3jMQ3IWg=";

    sparseCheckout = [
      "projects/rocfft"
      "shared"
    ];
  };

  patches = [
    # Fixes build timeout due to no log output during rocfft_aot step
    ./log-every-n-aot-jobs.patch
  ];

  nativeBuildInputs = [
    cmake
    clr
    python3
    rocm-cmake
  ];

  buildInputs = [
    sqlite
    hiprand
  ];

  cmakeFlags = [
    "-DSQLITE_USE_SYSTEM_PACKAGE=ON"
    "-DHIP_PLATFORM=amd"
    "-DBUILD_CLIENTS=OFF"
    "-DBUILD_SHARED_LIBS=ON"
    "-DUSE_HIPRAND=ON"
    "-DROCFFT_KERNEL_CACHE_ENABLE=ON"
    # Manually define CMAKE_INSTALL_<DIR>
    # See: https://github.com/NixOS/nixpkgs/pull/197838
    "-DCMAKE_INSTALL_BINDIR=bin"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
  ]
  ++ lib.optionals (gpuTargets != [ ]) [
    "-DGPU_TARGETS=${lib.concatStringsSep ";" gpuTargets}"
  ];

  requiredSystemFeatures = [ "big-parallel" ];
  sourceRoot = "${finalAttrs.src.name}/projects/rocfft";

  passthru = {
    benchmark = stdenv.mkDerivation {
      inherit (finalAttrs) version src;
      pname = "${finalAttrs.pname}-benchmark";

      nativeBuildInputs = [
        cmake
        clr
        rocm-cmake
      ];

      buildInputs = [
        boost
        finalAttrs.finalPackage
        openmp
        (python3.withPackages (
          ps: with ps; [
            pandas
            scipy
          ]
        ))
        rocrand
      ];

      postInstall = ''
        cp -a ../../../scripts/perf "$out/bin"
      '';

      sourceRoot = "${finalAttrs.src.name}/projects/rocfft/clients/rider";
    };

    samples = stdenv.mkDerivation {
      inherit (finalAttrs) version src;
      pname = "${finalAttrs.pname}-samples";

      nativeBuildInputs = [
        cmake
        clr
        rocm-cmake
      ];

      buildInputs = [
        boost
        finalAttrs.finalPackage
        openmp
        rocrand
      ];

      installPhase = ''
        runHook preInstall
        mkdir "$out"
        cp -a bin "$out"
        runHook postInstall
      '';

      sourceRoot = "${finalAttrs.src.name}/projects/rocfft/clients/samples";
    };

    test = stdenv.mkDerivation {
      inherit (finalAttrs) version src;
      pname = "${finalAttrs.pname}-test";

      nativeBuildInputs = [
        cmake
        clr
        rocm-cmake
      ];

      buildInputs = [
        boost
        fftw
        fftwFloat
        finalAttrs.finalPackage
        gtest
        openmp
        rocrand
        hiprand
      ];

      postInstall = ''
        rm -r "$out/lib/fftw"
        rmdir "$out/lib"
      '';

      sourceRoot = "${finalAttrs.src.name}/projects/rocfft/clients/tests";
    };

    updateScript = rocmUpdateScript { inherit finalAttrs; };
  };

  meta = {
    description = "FFT implementation for ROCm";
    homepage = "https://github.com/ROCm/rocm-libraries/tree/develop/projects/rocfft";
    license = with lib.licenses; [ mit ];
    platforms = lib.platforms.linux;
    teams = [ lib.teams.rocm ];
  };
})
