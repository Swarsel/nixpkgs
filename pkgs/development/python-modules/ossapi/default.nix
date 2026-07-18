{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  osrparse,
  requests,
  requests-oauthlib,
  setuptools,
  typing-utils,
}:

buildPythonPackage (finalAttrs: {
  pname = "ossapi";
  version = "5.3.5";

  src = fetchFromGitHub {
    owner = "Liam-DeVoe";
    repo = "ossapi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gkees4d12vCfx5KGNKm9NjW5XmRw+xJy2RISMOKzG+s=";
  };

  # Tests require Internet access and an osu! API key
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    osrparse
    requests
    requests-oauthlib
    typing-utils
  ];

  optional-dependencies = {
    async = [ aiohttp ];
  };

  pyproject = true;
  pythonImportsCheck = [ "ossapi" ];
  pythonRelaxDeps = [ "osrparse" ];

  meta = {
    description = "Python wrapper for the osu! API";
    homepage = "https://github.com/Liam-DeVoe/ossapi";
    changelog = "https://github.com/Liam-DeVoe/ossapi/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ wulpine ];
  };
})
