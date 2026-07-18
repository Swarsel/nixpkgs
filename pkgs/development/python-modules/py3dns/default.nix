{
  lib,
  buildPythonPackage,
  fetchPypi,
  flit-core,
}:

buildPythonPackage (finalAttrs: {
  pname = "py3dns";
  version = "4.0.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-mGUugOzsFDxg948OazQWMcqadWDt2N3fyGTAKQJhijk=";
  };

  doCheck = false;
  build-system = [ flit-core ];
  pyproject = true;

  meta = {
    description = "Python 3 DNS library";
    homepage = "https://launchpad.net/py3dns";
    license = lib.licenses.psfl;
  };
})
