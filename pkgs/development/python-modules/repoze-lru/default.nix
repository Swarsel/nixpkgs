{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "repoze-lru";
  version = "0.7";

  src = fetchPypi {
    inherit version;
    hash = "sha256-BCmnXhk4Dk7VDAaU4mrIgZtOp4Ue4fx1g8hXLbgK/3c=";
    pname = "repoze.lru";
  };

  nativeBuildInputs = [ setuptools ];
  nativeCheckInputs = [ pytestCheckHook ];

  disabledTests = [
    # time sensitive tests
    "test_different_timeouts"
    "test_renew_timeout"
  ];

  enabledTestPaths = [ "repoze/lru/tests.py" ];
  pyproject = true;
  pythonImportsCheck = [ "repoze.lru" ];
  pythonNamespaces = [ "repoze" ];

  meta = {
    description = "Tiny LRU cache implementation and decorator";
    homepage = "http://www.repoze.org/";
    changelog = "https://github.com/repoze/repoze.lru/blob/${version}/CHANGES.rst";
    license = lib.licenses.bsd0;
    maintainers = [ ];
  };
}
