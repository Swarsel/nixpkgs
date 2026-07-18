{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "offtrac";
  version = "0.1.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "06vd010pa1z7lyfj1na30iqzffr4kzj2k2sba09spik7drlvvl56";
  };

  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Trac xmlrpc library";
    homepage = "http://fedorahosted.org/offtrac";
    license = lib.licenses.gpl2;
  };
}
