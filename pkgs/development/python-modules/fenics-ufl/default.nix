{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "fenics-ufl";
  version = "2026.1.0";

  src = fetchFromGitHub {
    owner = "fenics";
    repo = "ufl";
    tag = finalAttrs.version;
    hash = "sha256-FwU9QmkyYuUfxt4v8sHFv+YNHldx1g0e/TDezijTUb4=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
  ];

  dependencies = [
    numpy
  ];

  pyproject = true;

  pythonImportsCheck = [
    "ufl"
    "ufl.algorithms"
    "ufl.core"
    "ufl.corealg"
    "ufl.formatting"
    "ufl.utils"
  ];

  meta = {
    description = "Unified Form Language";
    homepage = "https://fenicsproject.org";
    changelog = "https://github.com/fenics/ufl/releases/tag/${finalAttrs.version}";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ qbisi ];
    downloadPage = "https://github.com/fenics/ufl";
  };
})
