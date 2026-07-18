{
  lib,
  stdenv,
  fetchFromGitLab,
  arpack,
  mpiCheckPhaseHook,
  petsc,
  python3Packages,
  pythonSupport ? false,
  withArpack ? stdenv.hostPlatform.isLinux,
  withExamples ? false,
}:
let
  slepcPackages = petsc.petscPackages.overrideScope (
    final: prev: {
      inherit pythonSupport;
      arpack = final.callPackage arpack.override { useMpi = true; };
      mpiSupport = true;
    }
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "slepc";
  version = "3.25.1";

  src = fetchFromGitLab {
    owner = "slepc";
    repo = "slepc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CLZ3l9H41MrXa4IEkiiGS7VSs3ASNk5/DnLMmJ7NY5U=";
  };

  postPatch = ''
    # Fix slepc4py install prefix
    substituteInPlace config/packages/slepc4py.py \
      --replace-fail "slepc.prefixdir,'lib'" \
      "slepc.prefixdir,'${python3Packages.python.sitePackages}'"

    patchShebangs lib/slepc/bin
  '';

  nativeBuildInputs = [
    python3Packages.python
  ]
  ++ lib.optionals pythonSupport [
    python3Packages.setuptools
    python3Packages.cython
  ];

  buildInputs = [
    slepcPackages.mpi
  ]
  ++ lib.optionals withArpack [
    slepcPackages.arpack
  ];

  propagatedBuildInputs = [
    petsc
  ];

  configureFlags =
    lib.optionals withArpack [
      "--with-arpack=1"
    ]
    ++ lib.optionals pythonSupport [
      "--with-slepc4py=1"
    ];

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    mpiCheckPhaseHook
  ]
  ++ lib.optionals pythonSupport [
    python3Packages.pythonImportsCheckHook
    python3Packages.unittestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  enableParallelBuilding = true;
  installCheckTarget = [ "check_install" ];
  installTargets = [ (if withExamples then "install" else "install-lib") ];
  pythonImportsCheck = [ "slepc4py" ];
  setupHook = ./setup-hook.sh;

  unittestFlagsArray = [
    "-s"
    "src/binding/slepc4py/test"
    "-v"
  ];

  meta = {
    description = "Scalable Library for Eigenvalue Problem Computations";
    homepage = "https://slepc.upv.es";
    changelog = "https://gitlab.com/slepc/slepc/blob/v${finalAttrs.version}/CHANGELOG.md";

    license = with lib.licenses; [
      bsd2
    ];

    maintainers = with lib.maintainers; [ qbisi ];
    platforms = lib.platforms.unix;
    # Possible error running Fortran src/eps/tests/test7f with 1 MPI process
    broken = stdenv.hostPlatform.isDarwin && withArpack;
  };
})
