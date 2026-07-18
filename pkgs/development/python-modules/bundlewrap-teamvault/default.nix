{
  lib,
  buildPythonPackage,
  bundlewrap,
  fetchPypi,
  passlib,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "bundlewrap-teamvault";
  version = "3.1.5";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-kwJnfPMIhQsahIZFVtFb/YFgMUrnDt8t8+eJrig/ZTU=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    bundlewrap
    passlib
    requests
  ];

  # upstream has no checks
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "bwtv" ];

  meta = {
    description = "Pull secrets from TeamVault into your BundleWrap repo";
    homepage = "https://github.com/trehn/bundlewrap-teamvault";
    license = [ lib.licenses.gpl3 ];
    maintainers = [ ];
  };
}
