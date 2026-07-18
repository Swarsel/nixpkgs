{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  cachetools,
  cython,
  # dependencies
  decorator,
  # passthru
  firedrake,
  firedrake-fiat,
  firedrake-ufl,
  h5py,
  immutabledict,
  islpy,
  libsupermesh,
  loopy,
  matplotlib,
  mpi-pytest,
  mpi4py,
  mpiCheckPhaseHook,
  mpich,
  newScope,
  nix-update-script,
  numpy,
  packaging,
  petsc4py,
  petsctools,
  pkgconfig,
  progress,
  pyadjoint-ad,
  pybind11,
  pycparser,
  # tests
  pytest,
  python,
  pytools,
  requests,
  rtree,
  scipy,
  # build-system
  setuptools,
  sympy,
  writableTmpDirAsHomeHook,
}:
let
  firedrakePackages = lib.makeScope newScope (self: {
    inherit (petsc4py.petscPackages) mpi hdf5;
    h5py = self.callPackage h5py.override { };
    mpi-pytest = self.callPackage mpi-pytest.override { };
    mpi4py = self.callPackage mpi4py.override { };
  });
in
buildPythonPackage (finalAttrs: {
  pname = "firedrake";
  version = "2026.4.1";

  src = fetchFromGitHub {
    owner = "firedrakeproject";
    repo = "firedrake";
    tag = finalAttrs.version;
    hash = "sha256-scsxxs9k280R9+mM5CC7aIkKJ8rR1faexnUuMrDO9+k=";
  };

  # relax build-dependency petsc4py
  postPatch = ''
    substituteInPlace pyproject.toml --replace-fail \
      "petsc4py==3.25.0" "petsc4py"
  '';

  nativeBuildInputs = [
    firedrakePackages.mpi
  ];

  doCheck = true;

  nativeCheckInputs = [
    pytest
    firedrakePackages.mpi-pytest
    mpiCheckPhaseHook
    writableTmpDirAsHomeHook
  ];

  # run official smoke tests
  checkPhase = ''
    runHook preCheck

    $out/bin/firedrake-check

    runHook postCheck
  '';

  postFixup = lib.optionalString stdenv.hostPlatform.isDarwin ''
    install_name_tool -add_rpath ${libsupermesh}/${python.sitePackages}/libsupermesh/lib \
      $out/${python.sitePackages}/firedrake/cython/supermeshimpl.cpython-*-darwin.so
  '';

  __darwinAllowLocalNetworking = true;

  build-system = [
    cython
    libsupermesh
    firedrakePackages.mpi4py
    numpy
    pkgconfig
    pybind11
    setuptools
    petsc4py
    rtree
  ];

  dependencies = [
    decorator
    cachetools
    firedrakePackages.mpi4py
    firedrake-ufl
    firedrake-fiat
    firedrakePackages.h5py
    immutabledict
    libsupermesh
    loopy
    petsc4py
    petsctools
    numpy
    packaging
    pkgconfig
    progress
    pyadjoint-ad
    pycparser
    pytools
    requests
    rtree
    scipy
    sympy
    # required by script spydump
    matplotlib
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    islpy
  ];

  pyproject = true;
  pythonImportsCheck = [ "firedrake" ];

  pythonRelaxDeps = [
    "decorator"
  ];

  passthru = {
    # python updater script sets the wrong tag
    skipBulkUpdate = true;

    tests = lib.optionalAttrs stdenv.hostPlatform.isLinux {
      mpich = firedrake.override {
        petsc4py = petsc4py.override { mpi = mpich; };
      };
    };

    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "([0-9.]+)"
      ];
    };
  };

  meta = {
    description = "Automated Finite Element System";
    homepage = "https://www.firedrakeproject.org";

    license = with lib.licenses; [
      bsd3
      lgpl3Plus
    ];

    maintainers = with lib.maintainers; [ qbisi ];
    downloadPage = "https://github.com/firedrakeproject/firedrake";
  };
})
