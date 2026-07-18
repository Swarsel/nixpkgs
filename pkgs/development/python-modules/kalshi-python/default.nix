{
  lib,
  buildPythonPackage,
  certifi,
  cryptography,
  fetchPypi,
  lazy-imports,
  pydantic,
  pytestCheckHook,
  python-dateutil,
  setuptools,
  six,
  typing-extensions,
  urllib3,
}:

buildPythonPackage rec {
  pname = "kalshi-python";
  version = "2.1.4";

  src = fetchPypi {
    inherit version;
    hash = "sha256-FsHRuqfmdF31l5E/L08/eVhWkN7JhgJkFSUzMrYNuOY=";
    pname = "kalshi_python";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    certifi
    cryptography
    lazy-imports
    pydantic
    python-dateutil
    six
    typing-extensions
    urllib3
  ];

  pyproject = true;

  pythonImportsCheck = [
    "kalshi_python"
  ];

  meta = {
    description = "Official python SDK for algorithmic trading on Kalshi";
    homepage = "https://github.com/Kalshi/kalshi-python";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ robbiebuxton ];
  };
}
