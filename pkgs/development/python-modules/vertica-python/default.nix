{
  lib,
  buildPythonPackage,
  fetchPypi,
  mock,
  parameterized,
  pytestCheckHook,
  python-dateutil,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "vertica-python";
  version = "1.4.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-VCB4ri/t7mlK3tsE2Bxu3Cd7h+10QDApQhB9hqC81EU=";
  };

  nativeCheckInputs = [
    mock
    parameterized
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    python-dateutil
    six
  ];

  disabledTestPaths = [
    # Integration tests require an accessible Vertica db
    "vertica_python/tests/integration_tests"
  ];

  pyproject = true;
  pythonImportsCheck = [ "vertica_python" ];

  meta = {
    description = "Native Python client for Vertica database";
    homepage = "https://github.com/vertica/vertica-python";
    changelog = "https://github.com/vertica/vertica-python/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
