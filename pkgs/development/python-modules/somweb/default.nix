{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "somweb";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "taarskog";
    repo = "pySOMweb";
    rev = "v${version}";
    hash = "sha256-cLKEKDCMK7lCtbmj2KbhgJUCZpPnPI5tZvO5L+ey8qI=";
  };

  doCheck = false; # no tests
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "somweb" ];

  meta = {
    description = "Client library to control garage door operators produced by SOMMER through their SOMweb device";
    homepage = "https://github.com/taarskog/pysomweb";
    changelog = "https://github.com/taarskog/pySOMweb/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ uvnikita ];
    mainProgram = "somweb";
  };
}
