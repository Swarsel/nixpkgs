{
  lib,
  buildPythonPackage,
  cryptography,
  fetchPypi,
  setuptools,
  types-pyopenssl,
}:

buildPythonPackage rec {
  pname = "types-redis";
  version = "4.6.0.20241004";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-XxfSs/kJGrdThBU7+idmGf+hz2o42mDhDV5nScxbkC4=";
  };

  # Module doesn't have tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    cryptography
    types-pyopenssl
  ];

  pyproject = true;
  pythonImportsCheck = [ "redis-stubs" ];

  meta = {
    description = "Typing stubs for redis";
    homepage = "https://github.com/python/typeshed";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ gador ];
  };
}
