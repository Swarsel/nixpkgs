{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "httpagentparser";
  version = "1.9.9";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-I7yvCTJbF692NCg8pk2iP0hcXYO5SB/22IQTp8W8bek=";
  };

  # PyPi version does not include test directory
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "httpagentparser" ];

  meta = {
    description = "Module to extract OS, Browser, etc. information from http user agent string";
    homepage = "https://github.com/shon/httpagentparser";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ gador ];
  };
}
