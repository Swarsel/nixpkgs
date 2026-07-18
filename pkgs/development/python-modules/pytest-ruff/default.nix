{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  poetry-core,
  poetry-dynamic-versioning,
  # dependencies
  pytest,
  pytest-mock,
  # tests
  pytestCheckHook,
  ruff,
}:

buildPythonPackage rec {
  pname = "pytest-ruff";
  version = "0.5";

  src = fetchFromGitHub {
    owner = "businho";
    repo = "pytest-ruff";
    tag = "v${version}";
    hash = "sha256-fwtubbTRvPMSGhylP3H5zhIwHdeWeTbvxZY5doM+tvw=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-mock
  ];

  build-system = [
    poetry-core
    poetry-dynamic-versioning
  ];

  dependencies = [
    pytest
    ruff
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytest_ruff" ];

  meta = {
    description = "Pytest plugin to run ruff";
    homepage = "https://github.com/businho/pytest-ruff";
    changelog = "https://github.com/businho/pytest-ruff/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ baloo ];
  };
}
