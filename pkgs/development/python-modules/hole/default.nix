{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  hatchling,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "hole";
  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "home-assistant-ecosystem";
    repo = "python-hole";
    tag = finalAttrs.version;
    hash = "sha256-j9fwetfxc0HG+Ly+MpRYL3jDHAwtt+Ls3tUcizHuUrg=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ hatchling ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "hole" ];

  meta = {
    description = "Python API for interacting with a Pihole instance";
    homepage = "https://github.com/home-assistant-ecosystem/python-hole";
    changelog = "https://github.com/home-assistant-ecosystem/python-hole/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
