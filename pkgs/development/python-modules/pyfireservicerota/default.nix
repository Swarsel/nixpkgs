{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  oauthlib,
  pdm-backend,
  pytz,
  requests,
  websocket-client,
}:

buildPythonPackage rec {
  pname = "pyfireservicerota";
  version = "0.0.49";

  src = fetchFromGitHub {
    owner = "cyberjunky";
    repo = "python-fireservicerota";
    tag = version;
    hash = "sha256-EVMxAOP6haS+jkLD6pOZnu0yhhNMR+gCud2qXsycNbc=";
  };

  # no tests implemented
  doCheck = false;
  build-system = [ pdm-backend ];

  dependencies = [
    pytz
    oauthlib
    requests
    websocket-client
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyfireservicerota" ];

  meta = {
    description = "Python 3 API wrapper for FireServiceRota/BrandweerRooster";
    homepage = "https://github.com/cyberjunky/python-fireservicerota";
    changelog = "https://github.com/cyberjunky/python-fireservicerota/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
