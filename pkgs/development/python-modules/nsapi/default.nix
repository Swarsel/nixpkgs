{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytz,
  setuptools,
}:

buildPythonPackage rec {
  pname = "nsapi";
  version = "3.1.3";

  src = fetchFromGitHub {
    owner = "aquatix";
    repo = "ns-api";
    tag = "v${version}";
    hash = "sha256-Buhc0643WeX/4ZU/RkzNWiFjfEAJUtNL6uJ98unTnCg=";
  };

  # Project has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ pytz ];
  pyproject = true;
  pythonImportsCheck = [ "ns_api" ];

  meta = {
    description = "Python module to query routes of the Dutch railways";
    homepage = "https://github.com/aquatix/ns-api/";
    changelog = "https://github.com/aquatix/ns-api/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
