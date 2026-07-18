{
  lib,
  buildPythonPackage,
  fetchPypi,
  poetry-core,
}:

buildPythonPackage rec {
  pname = "babelfish";
  version = "0.6.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-3stnpGYIiNSEgKtpmDCYNxdBWNDxqmO+uxwuEaq5eqs=";
  };

  # no tests executed
  doCheck = false;
  build-system = [ poetry-core ];
  pyproject = true;
  pythonImportsCheck = [ "babelfish" ];

  meta = {
    description = "Module to work with countries and languages";
    homepage = "https://github.com/Diaoul/babelfish";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
