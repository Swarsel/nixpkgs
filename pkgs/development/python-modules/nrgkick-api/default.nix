{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  buildPythonPackage,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "nrgkick-api";
  version = "1.7.1";

  src = fetchFromGitHub {
    owner = "andijakl";
    repo = "nrgkick-api";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZOVSQOjFPVnm3xnkhp+KFC9YbASEfzB05VpSzKcXJiU=";
  };

  nativeCheckInputs = [
    aresponses
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "nrgkick_api" ];

  meta = {
    description = "Python client for NRGkick Gen2 EV charger local REST API";
    homepage = "https://github.com/andijakl/nrgkick-api";
    changelog = "https://github.com/andijakl/nrgkick-api/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
