{
  lib,
  buildPythonPackage,
  fetchPypi,
  numpy,
}:

buildPythonPackage rec {
  pname = "sgp4";
  version = "2.26";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-SNFXY7avk5P8ICQZBwVYjdNlD82QEzq5gOALxWB8YG4=";
  };

  nativeCheckInputs = [ numpy ];
  format = "setuptools";
  pythonImportsCheck = [ "sgp4" ];

  meta = {
    description = "Python version of the SGP4 satellite position library";
    homepage = "https://github.com/brandon-rhodes/python-sgp4";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ zane ];
  };
}
