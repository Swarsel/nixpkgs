{
  lib,
  fetchFromGitHub,
  aiohttp,
  aiortsp,
  buildPythonPackage,
  orjson,
  pycryptodomex,
  setuptools,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "reolink-aio";
  version = "0.21.4";

  src = fetchFromGitHub {
    owner = "starkillerOG";
    repo = "reolink_aio";
    tag = finalAttrs.version;
    hash = "sha256-qBGUhqjHur3vKhpHmOHIQUxeBn+YAIjECdm33o1c3jg=";
  };

  # All tests require a network device
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    aiortsp
    orjson
    pycryptodomex
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "reolink_aio" ];

  meta = {
    description = "Module to interact with the Reolink IP camera API";
    homepage = "https://github.com/starkillerOG/reolink_aio";
    changelog = "https://github.com/starkillerOG/reolink_aio/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
