{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "xstatic-font-awesome";
  version = "6.2.1.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-8HWHEJYShjjy4VOQINgid1TD2IXdaOfubemgEjUHaCg=";
    pname = "XStatic-Font-Awesome";
  };

  # no tests implemented
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Font Awesome packaged for python";
    homepage = "https://github.com/python-xstatic/font-awesome";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ aither64 ];
  };
}
