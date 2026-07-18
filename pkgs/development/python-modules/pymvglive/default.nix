{
  lib,
  buildPythonPackage,
  fetchPypi,
  requests,
}:

buildPythonPackage rec {
  pname = "pymvglive";
  version = "1.1.4";

  src = fetchPypi {
    inherit version;
    sha256 = "0sh4xm74im9qxzpbrlc5h1vnpgvpybnpvdcav1iws0b561zdr08c";
    pname = "PyMVGLive";
  };

  propagatedBuildInputs = [ requests ];
  format = "setuptools";

  meta = {
    description = "Get live-data from mvg-live.de";
    homepage = "https://github.com/pc-coholic/PyMVGLive";
    license = lib.licenses.free;
  };
}
