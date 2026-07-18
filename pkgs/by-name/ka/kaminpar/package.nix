{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gtest,
  kagen,
  kassert,
  mpi,
  mpiCheckPhaseHook,
  numactl,
  onetbb,
  sparsehash,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "kaminpar";
  version = "3.7.3";

  src = fetchFromGitHub {
    owner = "KaHIP";
    repo = "KaMinPar";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YjETyYnVcWzZqEv3z4xaBcdlWhSmsKC4PyFvUOZFBYA=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = lib.optional stdenv.hostPlatform.isLinux numactl;

  propagatedBuildInputs = [
    kagen
    kassert
    mpi
    onetbb
    sparsehash
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
    (lib.cmakeBool "KAMINPAR_BUILD_DISTRIBUTED" true)
    (lib.cmakeBool "KAMINPAR_BUILD_WITH_MTUNE_NATIVE" false)
  ];

  doCheck = true;

  nativeCheckInputs = [
    gtest
    mpiCheckPhaseHook
  ];

  __darwinAllowLocalNetworking = true;

  meta = {
    description = "Parallel heuristic solver for the balanced k-way graph partitioning problem";
    homepage = "https://github.com/KaHIP/KaMinPar";
    changelog = "https://github.com/KaHIP/KaMinPar/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dsalwasser ];
    platforms = lib.platforms.unix;
    mainProgram = "KaMinPar";
  };
})
