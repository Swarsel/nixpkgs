{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "lcn-frontend";
  version = "0.2.9";

  src = fetchPypi {
    inherit version;
    hash = "sha256-JQcnfBqwlDp31XRg2yBG9HZ8j4avxp57Qa3gBqT+67I=";
    pname = "lcn_frontend";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "lcn_frontend" ];

  meta = {
    description = "LCN panel for Home Assistant";
    homepage = "https://github.com/alengwenus/lcn-frontend";
    changelog = "https://github.com/alengwenus/lcn-frontend/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
