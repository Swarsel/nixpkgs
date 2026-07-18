{
  lib,
  buildPythonPackage,
  bundlewrap,
  fetchPypi,
  pykeepass,
  setuptools,
}:

buildPythonPackage rec {
  pname = "bundlewrap-keepass";
  version = "0.1.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-P41VtI8VIqSp1IXe7fzKDBGmmXmDLRm7v1qV1g35IC4";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    bundlewrap
    pykeepass
  ];

  # upstream has no checks
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "bwkeepass" ];

  meta = {
    description = "Use secrets from keepass in your BundleWrap repo";
    homepage = "https://pypi.org/project/bundlewrap-keepass";
    license = lib.licenses.gpl3;
    maintainers = [ ];
  };
}
