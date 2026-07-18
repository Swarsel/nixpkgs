{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "enzyme";
  version = "0.5.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-fPd5FI2eZusoOGA+rOFAxTw878i4/l1NWgOl+11Xs8E=";
  };

  nativeBuildInputs = [ setuptools ];
  # Tests rely on files obtained over the network
  doCheck = false;
  pyproject = true;

  meta = {
    description = "Python video metadata parser";
    homepage = "https://github.com/Diaoul/enzyme";
    license = lib.licenses.mit;
  };
}
