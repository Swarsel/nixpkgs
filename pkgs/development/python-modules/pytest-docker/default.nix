{
  lib,
  fetchFromGitHub,
  attrs,
  buildPythonPackage,
  py,
  pytest,
  pytest-mypy,
  pytest-pycodestyle,
  pytest-pylint,
  pytestCheckHook,
  requests,
  setuptools,
  types-requests,
  types-setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "pytest-docker";
  version = "3.2.5";

  src = fetchFromGitHub {
    owner = "avast";
    repo = "pytest-docker";
    tag = "v${version}";
    hash = "sha256-AkVLfCt2aQZrvSfa/5oXr95XUIR5mRqcMRz67kmuKKw=";
  };

  buildInputs = [ pytest ];

  nativeCheckInputs = [
    py
    pytest-mypy
    pytest-pycodestyle
    pytest-pylint
    pytestCheckHook
    requests
    types-requests
    types-setuptools
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];
  dependencies = [ attrs ];

  disabledTests = [
    # Tests wants to run docker
    "test_containers_and_volumes_get_cleaned_up"
    "test_main_fixtures_work"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytest_docker" ];

  meta = {
    description = "Docker-based integration tests";
    homepage = "https://github.com/avast/pytest-docker";
    changelog = "https://github.com/avast/pytest-docker/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
