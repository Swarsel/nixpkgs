{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "yeelightsunflower";
  version = "0.0.10";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-l4Rl6WSCK68/XBwCndonNu3kePDXfSs/uIXaCkrIT7g==";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "yeelightsunflower" ];

  meta = {
    description = "Python package for interacting with Yeelight Sunflower bulbs";
    homepage = "https://github.com/lindsaymarkward/python-yeelight-sunflower";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
