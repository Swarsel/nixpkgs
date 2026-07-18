{
  lib,
  fetchFromGitHub,
  blas,
  buildPythonPackage,
  cmake,
  fenics-ufl,
  lapack,
  matplotlib,
  nanobind,
  ninja,
  numpy,
  pkg-config,
  pytest-xdist,
  pytestCheckHook,
  scikit-build-core,
  scipy,
  sympy,
}:

buildPythonPackage (finalAttrs: {
  pname = "fenics-basix";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "fenics";
    repo = "basix";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MBrK7O3iQ0XFONebbAFXBom9i985EyTAXrOlSMiIpk8=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    blas
    lapack
  ];

  cmakeFlags = [
    # Prefer finding BLAS and LAPACK via pkg-config.
    # Avoid using the Accelerate.framework from the Darwin SDK.
    # Also, avoid mistaking BLAS for LAPACK.
    (lib.cmakeBool "BLA_PREFER_PKGCONFIG" true)
  ];

  nativeCheckInputs = [
    sympy
    scipy
    matplotlib
    fenics-ufl
    pytest-xdist
    pytestCheckHook
  ];

  build-system = [
    scikit-build-core
    nanobind
  ];

  dependencies = [
    numpy
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;

  pythonImportsCheck = [
    "basix"
  ];

  meta = {
    description = "Finite element definition and tabulation runtime library";
    homepage = "https://fenicsproject.org";
    changelog = "https://github.com/fenics/basix/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ qbisi ];
    downloadPage = "https://github.com/fenics/basix";
  };
})
