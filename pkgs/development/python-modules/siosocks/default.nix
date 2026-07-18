{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytest-asyncio,
  pytest-mock,
  pytest-trio,
  pytestCheckHook,
  setuptools,
  trio,
}:

buildPythonPackage rec {
  pname = "siosocks";
  version = "0.3.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-uja79vWhPYOhhTUBIh+XpS4GnrYJy0/XpDXXQjnyHWM=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-mock
    pytestCheckHook
    pytest-trio
  ];

  build-system = [ setuptools ];
  dependencies = [ trio ];

  disabledTestPaths = [
    # Timeout on Hydra
    "tests/test_trio.py"
    "tests/test_sansio.py"
    "tests/test_socketserver.py"
  ];

  disabledTests = [
    # network access
    "test_connection_direct_success"
    "test_connection_socks_success"
    "test_connection_socks_failed"
  ];

  pyproject = true;
  pythonImportsCheck = [ "siosocks" ];

  meta = {
    description = "Python socks 4/5 client/server library/framework";
    homepage = "https://github.com/pohmelie/siosocks";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
