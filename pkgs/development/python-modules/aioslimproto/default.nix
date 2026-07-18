{
  lib,
  fetchFromGitHub,
  aiohttp,
  async-timeout,
  buildPythonPackage,
  pillow,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "aioslimproto";
  version = "3.1.8";

  src = fetchFromGitHub {
    owner = "home-assistant-libs";
    repo = "aioslimproto";
    tag = finalAttrs.version;
    hash = "sha256-xHdwikriA6mcb7tmElqa6suINYxeyyGZQ5iO+P7dRCo=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'version = "0.0.0"' 'version = "${finalAttrs.version}"'
  '';

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    async-timeout
    pillow
  ];

  pyproject = true;
  pythonImportsCheck = [ "aioslimproto" ];

  meta = {
    description = "Module to control Squeezebox players";
    homepage = "https://github.com/home-assistant-libs/aioslimproto";
    changelog = "https://github.com/home-assistant-libs/aioslimproto/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
