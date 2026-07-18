{
  lib,
  fetchFromGitHub,
  aiohttp,
  awsiotsdk,
  buildPythonPackage,
  pyopenssl,
  setuptools,
}:

buildPythonPackage rec {
  pname = "thinqconnect";
  version = "1.0.13";

  src = fetchFromGitHub {
    owner = "thinq-connect";
    repo = "pythinqconnect";
    tag = version;
    hash = "sha256-0efPQ0fvBLi+Bp+JbBMRJPYFqRKBVpPQFyQ9rvHpEnY=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    awsiotsdk
    pyopenssl
  ];

  pyproject = true;
  pythonImportsCheck = [ "thinqconnect" ];

  meta = {
    description = "Module to interacting with the LG ThinQ Connect Open API";
    homepage = "https://github.com/thinq-connect/pythinqconnect";
    changelog = "https://github.com/thinq-connect/pythinqconnect/blob/${src.tag}/RELEASE_NOTES.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
