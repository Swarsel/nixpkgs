{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  packaging,
  petsc4py,
  pytestCheckHook,
  setuptools,
  slepc4py,
}:

buildPythonPackage (finalAttrs: {
  pname = "petsctools";
  version = "2026.0";

  src = fetchFromGitHub {
    owner = "firedrakeproject";
    repo = "petsctools";
    tag = finalAttrs.version;
    hash = "sha256-IMDPjhyehOkyifSJ7nOJQbZu21w6Xyyz9fv/WLDpEgQ=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ finalAttrs.passthru.optional-dependencies.petsc4py;

  build-system = [
    setuptools
  ];

  dependencies = [
    packaging
  ];

  disabledTests = [
    # Expects a double slash when PETSC_ARCH is empty.
    "test_get_petsc_dirs"
  ];

  optional-dependencies = {
    petsc4py = [ petsc4py ];
    slepc4py = [ slepc4py ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "petsctools"
  ];

  meta = {
    description = "Pythonic extensions for petsc4py and slepc4py";
    homepage = "https://github.com/firedrakeproject/petsctools";
    changelog = "https://github.com/firedrakeproject/petsctools/releases/tag/${finalAttrs.version}";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ qbisi ];
  };
})
