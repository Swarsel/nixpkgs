{
  lib,
  buildPythonPackage,
  fetchPypi,
  python,
}:

buildPythonPackage rec {
  pname = "pynzb";
  version = "0.1.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0735b3889a1174bbb65418ee503629d3f5e4a63f04b16f46ffba18253ec3ef17";
  };

  # Can't get them working
  doCheck = false;

  checkPhase = ''
    ${python.interpreter} -m unittest -s pynzb -t .
  '';

  format = "setuptools";

  meta = {
    description = "Unified API for parsing NZB files";
    homepage = "https://github.com/ericflo/pynzb";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
