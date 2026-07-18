{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "osrf-pycommon";
  version = "2.1.7";

  src = fetchFromGitHub {
    owner = "osrf";
    repo = "osrf_pycommon";
    tag = finalAttrs.version;
    hash = "sha256-gKYeCvcJDJkW2OYP7K3eyztuPSkzE8dHoTUh4sKvxcM=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  disabledTestPaths = [
    "tests/test_code_format.py" # flake8 based tests don't work
  ];

  pyproject = true;
  pythonImportsCheck = [ "osrf_pycommon" ];

  meta = {
    description = "Commonly needed Python modules used by Python software developed at OSRF";
    homepage = "http://osrf-pycommon.readthedocs.org/";
    changelog = "https://github.com/osrf/osrf_pycommon/blob/${finalAttrs.src.tag}/CHANGELOG.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ guelakais ];
    downloadPage = "https://github.com/osrf/osrf_pycommon";
  };
})
