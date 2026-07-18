{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytest,
  unzip,
}:

buildPythonPackage rec {
  pname = "pytest-catchlog";
  version = "1.2.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1w7wxh27sbqwm4jgwrjr9c2gy384aca5jzw9c0wzhl0pmk2mvqab";
    extension = "zip";
  };

  nativeBuildInputs = [ unzip ];
  buildInputs = [ pytest ];
  # Requires pytest < 3.1
  doCheck = false;
  checkPhase = "make test";
  format = "setuptools";

  meta = {
    description = "py.test plugin to catch log messages. This is a fork of pytest-capturelog";
    homepage = "https://pypi.org/project/pytest-catchlog/";
    license = lib.licenses.mit;
  };
}
