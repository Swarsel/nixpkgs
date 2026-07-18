{
  lib,
  stdenv,
  fetchFromGitHub,
  cereal,
  ceres-solver,
  clp,
  cmake,
  coin-utils,
  eigen,
  lemon-graph,
  libjpeg,
  libpng,
  libtiff,
  llvmPackages,
  nix-update-script,
  osi,
  pkg-config,
  zlib,
  enableDocs ? false,
  enableExamples ? false,
  enableShared ? !stdenv.hostPlatform.isStatic,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "openmvg";
  version = "2.1";

  src = fetchFromGitHub {
    owner = "openmvg";
    repo = "openmvg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vG+tW9Gl/DAUL8DeY+rJVDJH/oMPH3XyZMUgzjtwFv0=";
  };

  # Pretend we checked out the dependency submodules
  postPatch = ''
    mkdir src/dependencies/cereal/include
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    cereal
    ceres-solver
    clp
    coin-utils
    eigen
    lemon-graph
    libjpeg
    libpng
    libtiff
    llvmPackages.openmp
    osi
    zlib
  ];

  # flann is missing because the lz4 dependency isn't propagated: https://github.com/openMVG/openMVG/issues/1265
  cmakeFlags = [
    (lib.cmakeBool "OpenMVG_BUILD_EXAMPLES" enableExamples)
    (lib.cmakeBool "OpenMVG_BUILD_DOC" enableDocs)
    (lib.cmakeFeature "TARGET_ARCHITECTURE" "generic")
    (lib.cmakeFeature "CLP_INCLUDE_DIR_HINTS" "${lib.getDev clp}/include")
    (lib.cmakeFeature "COINUTILS_INCLUDE_DIR_HINTS" "${lib.getDev coin-utils}/include")
    (lib.cmakeFeature "LEMON_INCLUDE_DIR_HINTS" "${lib.getDev lemon-graph}/include")
    (lib.cmakeFeature "OSI_INCLUDE_DIR_HINTS" "${lib.getDev osi}/include")

    # Compatibility with CMake < 3.5 has been removed from CMake.
    (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.5")
  ]
  ++ lib.optionals enableShared [
    (lib.cmakeBool "OpenMVG_BUILD_SHARED" true)
  ];

  cmakeDir = "./src";
  dontUseCmakeBuildDir = true;
  # This can be enabled, but it will exhause virtual memory on most machines.
  enableParallelBuilding = false;
  # Without hardeningDisable, certain flags are passed to the compile that break the build (primarily string format errors)
  hardeningDisable = [ "all" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Library for computer-vision scientists and targeted for the Multiple View Geometry community";
    homepage = "https://openmvg.readthedocs.io/en/latest/";
    changelog = "https://github.com/openMVG/openMVG/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mpl20;

    maintainers = with lib.maintainers; [
      mdaiter
      bouk
    ];

    platforms = lib.platforms.unix;
    downloadPage = "https://github.com/openMVG/openMVG";
  };
})
