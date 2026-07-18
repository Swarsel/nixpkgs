{
  lib,
  stdenv,
  adios2,
  buildPythonPackage,
  cffi,
  # nativeBuildInputs
  cmake,
  # buildInputs
  dolfinx,
  fenics-basix,
  # passthru.tests
  fenics-dolfinx,
  fenics-ffcx,
  fenics-ufl,
  kahip,
  matplotlib,
  mpi4py,
  mpiCheckPhaseHook,
  mpich,
  nanobind,
  ninja,
  # dependency
  numpy,
  petsc4py,
  pkg-config,
  pytestCheckHook,
  # build-system
  scikit-build-core,
  # nativeCheckInputs
  scipy,
  slepc4py,
  writableTmpDirAsHomeHook,
  # custom options
  withParmetis ? false,
}:

let
  fenicsPackages = petsc4py.petscPackages.overrideScope (
    final: prev: {
      adios2 = final.callPackage adios2.override { };
      dolfinx = final.callPackage dolfinx.override { inherit withParmetis; };
      kahip = final.callPackage kahip.override { };
      slepc = final.callPackage slepc4py.override { };
    }
  );
in
buildPythonPackage (finalAttrs: {
  inherit (dolfinx)
    version
    src
    ;

  pname = "fenics-dolfinx";

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    fenicsPackages.mpi
  ];

  buildInputs = [
    fenicsPackages.dolfinx
  ];

  preConfigure = ''
    cd python
  '';

  nativeCheckInputs = [
    scipy
    matplotlib
    pytestCheckHook
    writableTmpDirAsHomeHook
    mpiCheckPhaseHook
  ];

  preCheck = ''
    cd test
  '';

  build-system = [
    scikit-build-core
    nanobind
  ];

  dependencies = [
    numpy
    cffi
    fenics-basix
    fenics-ffcx
    fenics-ufl
    petsc4py
    fenicsPackages.slepc
    fenicsPackages.adios2
    fenicsPackages.kahip
    (mpi4py.override { inherit (fenicsPackages) mpi; })
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;

  pythonImportsCheck = [
    "dolfinx"
  ];

  pythonRelaxDeps = [
    "fenics-ufl"
  ];

  passthru = {
    tests = {
      complex = fenics-dolfinx.override {
        petsc4py = petsc4py.override { scalarType = "complex"; };
      };
    }
    // lib.optionalAttrs stdenv.hostPlatform.isLinux {
      mpich = fenics-dolfinx.override {
        petsc4py = petsc4py.override { mpi = mpich; };
      };
    };
  };

  meta = {
    description = "Computational environment of FEniCSx and implements the FEniCS Problem Solving Environment in C++ and Python";
    homepage = "https://fenicsproject.org";
    changelog = "https://github.com/fenics/dolfinx/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      bsd2
      lgpl3Plus
    ];

    maintainers = with lib.maintainers; [ qbisi ];
    platforms = lib.platforms.unix;
    downloadPage = "https://github.com/fenics/dolfinx";
  };
})
