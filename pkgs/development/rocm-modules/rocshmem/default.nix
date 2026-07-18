{
  lib,
  stdenv,
  fetchFromGitHub,
  clr,
  cmake,
  mpi,
  rocm-cmake,
  rocm-core,
  rocm-runtime,
  rocmUpdateScript,
  buildExamples ? false,
  gpuTargets ? (clr.localGpuTargets or [ ]),
  useMpi ? true,
  useReverseOffload ? useMpi,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rocshmem${clr.gpuArchSuffix}";
  version = "7.2.3";

  src = fetchFromGitHub {
    owner = "ROCm";
    repo = "rocSHMEM";
    rev = "rocm-${finalAttrs.version}";
    hash = "sha256-7TiUABwCVPvosoLdR8zN+QGiX+OD7iD+HKMLnGMmRYA=";
  };

  nativeBuildInputs = [
    cmake
    rocm-cmake
    clr
  ];

  buildInputs = [
    rocm-runtime
  ]
  ++ lib.optionals useMpi [
    mpi
  ];

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_BUILD_TYPE" "Release")
    (lib.cmakeBool "CMAKE_POSITION_INDEPENDENT_CODE" true)
    (lib.cmakeFeature "CMAKE_CXX_COMPILER" "hipcc")
    (lib.cmakeFeature "ROCM_PATH" "${clr}")
    (lib.cmakeFeature "ROCM_VERSION" rocm-core.ROCM_LIBPATCH_VERSION)
    (lib.cmakeBool "USE_IPC" true)
    (lib.cmakeBool "USE_RO" useReverseOffload)
    (lib.cmakeBool "USE_SINGLE_NODE" (!useMpi))
    (lib.cmakeBool "USE_EXTERNAL_MPI" useMpi)
    (lib.cmakeBool "BUILD_EXAMPLES" buildExamples)
    (lib.cmakeFeature "CMAKE_INSTALL_BINDIR" "bin")
    (lib.cmakeFeature "CMAKE_INSTALL_LIBDIR" "lib")
    (lib.cmakeFeature "CMAKE_INSTALL_INCLUDEDIR" "include")
  ]
  ++ lib.optionals (gpuTargets != [ ]) [
    (lib.cmakeFeature "GPU_TARGETS" (lib.concatStringsSep ";" gpuTargets))
  ];

  passthru.updateScript = rocmUpdateScript { inherit finalAttrs; };

  meta = {
    description = "The ROCm OpenSHMEM (rocSHMEM) runtime";
    homepage = "https://github.com/ROCm/rocSHMEM";
    license = with lib.licenses; [ mit ];
    platforms = lib.platforms.linux;
    teams = [ lib.teams.rocm ];
  };
})
