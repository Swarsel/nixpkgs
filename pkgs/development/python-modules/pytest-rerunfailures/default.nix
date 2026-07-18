{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  packaging,
  pytest,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pytest-rerunfailures";
  version = "16.3";

  src = fetchFromGitHub {
    owner = "pytest-dev";
    repo = "pytest-rerunfailures";
    tag = version;
    hash = "sha256-T4l4AoUHvT6GjHyRK2TA3vPTxRicZ5pvgFgDtbkOGMw=";
  };

  buildInputs = [ pytest ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ packaging ];
  pyproject = true;

  meta = {
    description = "Pytest plugin to re-run tests to eliminate flaky failures";
    homepage = "https://github.com/pytest-dev/pytest-rerunfailures";
    changelog = "https://github.com/pytest-dev/pytest-rerunfailures/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ das-g ];
  };
}
