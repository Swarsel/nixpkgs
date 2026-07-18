{
  lib,
  fetchFromGitHub,
  aiohttp,
  async-timeout,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "webthing-ws";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "home-assistant-ecosystem";
    repo = "webthing-ws";
    tag = finalAttrs.version;
    hash = "sha256-j7nc4yJczDs28RVFDHeQ2ZIG9mIW2m25AAeErVKi4E4=";
  };

  # Module has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    async-timeout
  ];

  pyproject = true;
  pythonImportsCheck = [ "webthing_ws" ];

  meta = {
    description = "WebThing WebSocket consumer and API client";
    homepage = "https://github.com/home-assistant-ecosystem/webthing-ws";
    changelog = "https://github.com/home-assistant-ecosystem/webthing-ws/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
