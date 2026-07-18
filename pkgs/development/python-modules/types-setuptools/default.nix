{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "types-setuptools";
  version = "80.9.0.20251223";

  src = fetchPypi {
    inherit version;
    hash = "sha256-00EQWa4vXwOYUhfYasYITv6iyenKzV8Iae+VDzCBabI=";
    pname = "types_setuptools";
  };

  nativeBuildInputs = [ setuptools ];
  # Module doesn't have tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "setuptools-stubs" ];

  meta = {
    description = "Typing stubs for setuptools";
    homepage = "https://github.com/python/typeshed";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
