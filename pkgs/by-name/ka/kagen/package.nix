{
  lib,
  stdenv,
  fetchFromGitHub,
  cgal,
  cmake,
  ctestCheckHook,
  gtest,
  imagemagick,
  mpi,
  mpiCheckPhaseHook,
  pkg-config,
  sparsehash,
  testers,
  withExamples ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kagen";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "KarlsruheGraphGeneration";
    repo = "kagen";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VLQxeI9EzeJEp1krlLPRSct3SQmAF8cj34u3fkmppQg=";
    # use vendor libmorton and xxhash
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    imagemagick
  ];

  propagatedBuildInputs = [
    mpi
    cgal
    sparsehash
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
    (lib.cmakeBool "KAGEN_USE_BUNDLED_GTEST" false)
    (lib.cmakeBool "KAGEN_BUILD_EXAMPLES" withExamples)
    (lib.cmakeBool "KAGEN_BUILD_TESTS" finalAttrs.finalPackage.doCheck)
  ];

  doCheck = true;

  nativeCheckInputs = [
    gtest
    ctestCheckHook
    mpiCheckPhaseHook
  ];

  __darwinAllowLocalNetworking = true;

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # flaky tests on darwin
    "test_rgg2d.2cores"
    "test_rgg2d.4cores"
    "test_edge_weights.2cores"
    "test_edge_weights.4cores"
    "test_permutation.2cores"
    "test_permutation.4cores"
  ];

  passthru = {
    tests = {
      cmake-config = testers.hasCmakeConfigModules {
        moduleNames = [ "KaGen" ];
        package = finalAttrs.finalPackage;
      };
    };
  };

  meta = {
    description = "Communication-free Massively Distributed Graph Generators";
    homepage = "https://github.com/KarlsruheGraphGeneration/KaGen";
    changelog = "https://github.com/KarlsruheGraphGeneration/KaGen/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      bsd2
      mit
      # boost license
      lib.licenses.boost
    ];

    maintainers = with lib.maintainers; [ qbisi ];
    platforms = lib.platforms.unix;
    mainProgram = "KaGen";
  };
})
