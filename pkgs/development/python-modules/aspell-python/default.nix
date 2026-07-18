{
  lib,
  aspell,
  aspellDicts,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "aspell-python";
  version = "1.15";

  src = fetchPypi {
    inherit version;
    hash = "sha256-IEKRDmQY5fOH9bQk0dkUAy7UzpBOoZW4cNtVvLMcs40=";
    extension = "tar.bz2";
    pname = "aspell-python-py3";
  };

  buildInputs = [ aspell ];
  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    export ASPELL_CONF="dict-dir ${aspellDicts.en}/lib/aspell"
    export HOME=$(mktemp -d)
  '';

  build-system = [ setuptools ];

  disabledTests = [
    # https://github.com/WojciechMula/aspell-python/issues/22
    "test_add"
    "test_get"
    "test_saveall"
  ];

  enabledTestPaths = [ "test/unittests.py" ];
  pyproject = true;
  pythonImportsCheck = [ "aspell" ];

  meta = {
    description = "Python wrapper for aspell (C extension and Python version)";
    homepage = "https://github.com/WojciechMula/aspell-python";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
