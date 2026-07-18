{
  lib,
  fetchFromGitHub,
  aiohttp,
  aiomqtt,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "yoto-api";
  version = "4.3.1";

  src = fetchFromGitHub {
    owner = "cdnninja";
    repo = "yoto_api";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Hy2OE8jol/ttZ1MsIC4EzkYa72DINwcjsHflo8+a7xo=";
  };

  # All tests require access to and authentication with the Yoto API (api.yotoplay.com).
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    aiomqtt
  ];

  pyproject = true;
  pythonImportsCheck = [ "yoto_api" ];

  meta = {
    description = "Python package that makes it a bit easier to work with the yoto play API";
    homepage = "https://github.com/cdnninja/yoto_api";
    changelog = "https://github.com/cdnninja/yoto_api/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ seberm ];
    platforms = lib.platforms.unix;
  };
})
