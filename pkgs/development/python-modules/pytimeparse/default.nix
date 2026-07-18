{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pytimeparse";
  version = "1.1.8";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-6GE2R3vpJNfmcGRqmFYZV+jKcwjUSEHiH13ep1dVago=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  enabledTestPaths = [ "pytimeparse/tests/testtimeparse.py" ];
  pyproject = true;
  pythonImportsCheck = [ "pytimeparse" ];

  meta = {
    description = "Library to parse various kinds of time expressions";
    homepage = "https://github.com/wroberts/pytimeparse";
    changelog = "https://github.com/wroberts/pytimeparse/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
