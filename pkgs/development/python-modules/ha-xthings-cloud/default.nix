{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pyjwt,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "ha-xthings-cloud";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "XthingsJacobs";
    repo = "ha-xthings-cloud";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Qz/JOvOcT7GicqduNOi4r9F2xqtQLX9d8D1zQb5oAUo=";
  };

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    pyjwt
  ];

  pyproject = true;
  pythonImportsCheck = [ "ha_xthings_cloud" ];

  meta = {
    description = "Async Python client for Xthings Cloud API";
    homepage = "https://github.com/XthingsJacobs/ha-xthings-cloud";
    changelog = "https://github.com/XthingsJacobs/ha-xthings-cloud/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
