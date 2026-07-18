{
  lib,
  buildPythonPackage,
  django,
  fetchPypi,
  pycrypto,
  six,
}:

buildPythonPackage rec {
  pname = "libthumbor";
  version = "2.0.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-1PsiFZrTDVQqy8A3nkaM5LdPiBoriRgHkklTOiczN+g=";
  };

  buildInputs = [ django ];

  propagatedBuildInputs = [
    six
    pycrypto
  ];

  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "libthumbor" ];

  meta = {
    description = "Python extension to thumbor";
    homepage = "https://github.com/heynemann/libthumbor";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
