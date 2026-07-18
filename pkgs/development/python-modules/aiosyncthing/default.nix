{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  deprecated,
  expects,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-mock,
  pytestCheckHook,
  setuptools,
  yarl,
}:

buildPythonPackage rec {
  pname = "aiosyncthing";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "zhulik";
    repo = "aiosyncthing";
    tag = "v${version}";
    hash = "sha256-0jx61zs6yQqAIwSOO1zCUOkoZES+K/POtIGoWzr29bI=";
  };

  nativeCheckInputs = [
    aioresponses
    expects
    pytestCheckHook
    pytest-cov-stub
    pytest-asyncio
    pytest-mock
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    deprecated
    yarl
  ];

  pyproject = true;
  pytestFlags = [ "--asyncio-mode=auto" ];
  pythonImportsCheck = [ "aiosyncthing" ];

  meta = {
    description = "Python client for the Syncthing REST API";
    homepage = "https://github.com/zhulik/aiosyncthing";
    changelog = "https://github.com/zhulik/aiosyncthing/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
