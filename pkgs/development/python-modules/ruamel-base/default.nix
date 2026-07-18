{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "ruamel-base";
  version = "1.0.0";

  src = fetchPypi {
    inherit version;
    sha256 = "1wswxrn4givsm917mfl39rafgadimf1sldpbjdjws00g1wx36hf0";
    pname = "ruamel.base";
  };

  # no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "ruamel.base" ];
  pythonNamespaces = [ "ruamel" ];

  meta = {
    description = "Common routines for ruamel packages";
    homepage = "https://sourceforge.net/projects/ruamel-base/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
