{
  lib,
  buildPythonPackage,
  fetchPypi,
  isPy3k,
  isPyPy,
}:

buildPythonPackage rec {
  pname = "pyptlib";
  version = "0.0.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "01y6vbwncqb0hxlnin6whd9wrrm5my4qzjhk76fnix78v7ip515r";
  };

  doCheck = false; # No such file or directory errors on 32bit
  disabled = isPyPy || isPy3k;
  format = "setuptools";

  meta = {
    description = "Python implementation of the Pluggable Transports for Circumvention specification for Tor";
    homepage = "https://pypi.org/project/pyptlib/";
    license = lib.licenses.bsd2;
  };
}
