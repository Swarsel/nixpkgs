{
  lib,
  fetchFromGitHub,
  addBinToPathHook,
  buildPythonPackage,
  cffi,
  fenics-basix,
  fenics-ufl,
  numba,
  numpy,
  pytestCheckHook,
  setuptools,
  sympy,
}:

buildPythonPackage (finalAttrs: {
  pname = "fenics-ffcx";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "fenics";
    repo = "ffcx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pAnoCLf1ObJ2jDOdQ0cr3qu3z+rNeAVFPnvegp/KqeM=";
  };

  nativeCheckInputs = [
    sympy
    numba
    pytestCheckHook
    addBinToPathHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    numpy
    cffi
    setuptools
    fenics-ufl
    fenics-basix
  ];

  pyproject = true;

  pythonImportsCheck = [
    "ffcx"
  ];

  pythonRelaxDeps = [
    "fenics-ufl"
  ];

  meta = {
    description = "FEniCSx Form Compiler";
    homepage = "https://fenicsproject.org";
    changelog = "https://github.com/fenics/ffcx/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      unlicense
      lgpl3Plus
    ];

    maintainers = with lib.maintainers; [ qbisi ];
    mainProgram = "ffcx";
    downloadPage = "https://github.com/fenics/ffcx";
  };
})
