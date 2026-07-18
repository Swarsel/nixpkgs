{
  lib,
  fetchFromGitLab,
  aiofiles,
  aiohttp,
  authcaptureproxy,
  backoff,
  beautifulsoup4,
  buildPythonPackage,
  certifi,
  cryptography,
  poetry-core,
  pyotp,
  requests,
  simplejson,
  yarl,
}:

buildPythonPackage (finalAttrs: {
  pname = "alexapy";
  version = "1.29.25";

  src = fetchFromGitLab {
    owner = "keatontaylor";
    repo = "alexapy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-P/hvgqZVaBJF5dbmHrDjQMC+pwV3EEhKyFIS5KmhgD4=";
  };

  # Module has no tests (only a websocket test which seems unrelated to the module)
  doCheck = false;
  build-system = [ poetry-core ];

  dependencies = [
    aiofiles
    aiohttp
    authcaptureproxy
    backoff
    beautifulsoup4
    certifi
    cryptography
    pyotp
    requests
    simplejson
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "alexapy" ];
  pythonRelaxDeps = [ "aiofiles" ];

  meta = {
    description = "Python Package for controlling Alexa devices (echo dot, etc) programmatically";
    homepage = "https://gitlab.com/keatontaylor/alexapy";
    changelog = "https://gitlab.com/keatontaylor/alexapy/-/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
