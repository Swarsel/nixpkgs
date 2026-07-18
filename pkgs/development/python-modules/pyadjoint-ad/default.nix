{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  checkpoint-schedules,
  pytestCheckHook,
  scipy,
  setuptools,
  sympy,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyadjoint-ad";
  version = "2026.4.1";

  src = fetchFromGitHub {
    owner = "dolfin-adjoint";
    repo = "pyadjoint";
    tag = finalAttrs.version;
    hash = "sha256-ChtZQ5MJeQt1CqAsFHTCwbIJrcwBKlNxSF5zi6pHLsA=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
  ];

  dependencies = [
    scipy
    sympy
    checkpoint-schedules
  ];

  enabledTestPaths = [
    "tests/pyadjoint"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "numpy_adjoint"
    "pyadjoint"
    "pyadjoint.optimization"
  ];

  meta = {
    description = "High-level automatic differentiation library";
    homepage = "https://github.com/dolfin-adjoint/pyadjoint";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ qbisi ];
  };
})
