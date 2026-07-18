{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "types-ujson";
  version = "5.10.0.20250822";

  src = fetchPypi {
    inherit version;
    hash = "sha256-CnlVWOH3hTI3PPPwPzWx8IvGDVLZJBh7l5le41l7oAY=";
    pname = "types_ujson";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "ujson-stubs" ];

  meta = {
    description = "Typing stubs for ujson";
    homepage = "https://github.com/python/typeshed";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ centromere ];
  };
}
