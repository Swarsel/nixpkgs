{
  lib,
  buildPythonPackage,
  docopt,
  fetchPypi,
  para,
}:

buildPythonPackage rec {
  pname = "mwcli";
  version = "0.0.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ADMb0P8WtXIcnGJ02R4l/TVfRewHc8ig45JurAWHGaA=";
  };

  propagatedBuildInputs = [
    docopt
    para
  ];

  # Tests require mwxml which itself depends on this package (circular dependency)
  doCheck = false;
  format = "setuptools";
  # Prevent circular dependency
  pythonRemoveDeps = [ "mwxml" ];

  meta = {
    description = "Set of helper functions and classes for mediawiki-utilities command-line utilities";
    homepage = "https://github.com/mediawiki-utilities/python-mwcli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
