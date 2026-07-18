{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  httpx,
  lxml,
  pkce,
  setuptools,
  shortuuid,
}:

buildPythonPackage rec {
  pname = "wolf-comm";
  version = "0.0.52";

  src = fetchFromGitHub {
    owner = "janrothkegel";
    repo = "wolf-comm";
    tag = version;
    hash = "sha256-IdV52+/2GTsAtlN3mvdtSf6B2WS6w3SvAOaZyZA/e+I=";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    httpx
    lxml
    pkce
    shortuuid
  ];

  pyproject = true;
  pythonImportsCheck = [ "wolf_comm" ];

  meta = {
    description = "Communicate with Wolf SmartSet Cloud";
    homepage = "https://github.com/janrothkegel/wolf-comm";
    changelog = "https://github.com/janrothkegel/wolf-comm/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
