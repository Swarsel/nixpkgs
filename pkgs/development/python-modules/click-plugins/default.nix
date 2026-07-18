{
  lib,
  buildPythonPackage,
  click,
  fetchPypi,
  pytest,
  setuptools,
}:

buildPythonPackage rec {
  pname = "click-plugins";
  version = "1.1.1.2";

  src = fetchPypi {
    inherit version;
    sha256 = "sha256-1685hKmdJDwTGqGoKDMedjD0qIqXQf0FySeyBLz5ImE=";
    pname = "click_plugins";
  };

  nativeCheckInputs = [ pytest ];
  build-system = [ setuptools ];
  dependencies = [ click ];
  pyproject = true;

  meta = {
    description = "Extension module for click to enable registering CLI commands";
    homepage = "https://github.com/click-contrib/click-plugins";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
