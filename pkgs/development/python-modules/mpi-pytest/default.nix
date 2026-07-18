{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mpi4py,
  mpiCheckPhaseHook,
  pytest,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "mpi-pytest";
  version = "2025.7";

  src = fetchFromGitHub {
    owner = "firedrakeproject";
    repo = "mpi-pytest";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TZj1hObMVzYfAUC0UjXMvUThbKCNdiB1FMSA0AHjZ9s=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    mpiCheckPhaseHook
    mpi4py.mpi
  ];

  __darwinAllowLocalNetworking = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    mpi4py
    pytest
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pytest_mpi"
  ];

  meta = {
    description = "Pytest plugin that lets you run tests in parallel with MPI";
    homepage = "https://github.com/firedrakeproject/mpi-pytest";
    changelog = "https://github.com/firedrakeproject/mpi-pytest/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ qbisi ];
  };
})
