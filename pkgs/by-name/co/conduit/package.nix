{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  # passthru
  conduit,
  nix-update-script,
  openmpi,
  python3Packages,
  mpiSupport ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "conduit";
  version = "0.9.7";

  src = fetchFromGitHub {
    owner = "LLNL";
    repo = "conduit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DmnHGj6Q/i+wVNIbaTGrFX9f0Kry2X5bC7zahXv29I4=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = lib.optionals mpiSupport [
    openmpi
  ];

  cmakeFlags = [
    # Don't leak kernel version into the build output for reproducibility
    (lib.cmakeFeature "CMAKE_SYSTEM_VERSION" "")
    (lib.cmakeBool "ENABLE_MPI" mpiSupport)
  ];

  doInstallCheck = true;

  installCheckPhase =
    let
      excludedTests = lib.optionals stdenv.hostPlatform.isDarwin [
        # SIGTRAP***Exception
        "t_conduit_fixed_size_vector"
      ];

      excludedTestsString = lib.optionalString (
        excludedTests != [ ]
      ) "-E '^(${builtins.concatStringsSep "|" excludedTests})$'";
    in
    ''
      runHook preInstallCheck

      ctest --output-on-failure ${excludedTestsString}

      runHook postInstallCheck
    '';

  cmakeDir = "../src";

  passthru = {
    tests = {
      pythonModule = python3Packages.conduit;
      pythonModuleWithMpi = python3Packages.conduit-mpi;
      withMpi = conduit.override { mpiSupport = true; };
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Simplified Data Exchange for HPC Simulations";
    homepage = "https://github.com/LLNL/conduit";
    changelog = "https://github.com/LLNL/conduit/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.bsd3Lbnl;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    platforms = lib.platforms.all;
  };
})
