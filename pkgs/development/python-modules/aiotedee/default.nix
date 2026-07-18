{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  mashumaro,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "aiotedee";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "zweckj";
    repo = "aiotedee";
    tag = "v${version}";
    hash = "sha256-0+wUQRsMb9y8XUwwUX3exIzkaAFLYNUpsAr0MgnkMIo=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    mashumaro
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiotedee" ];

  meta = {
    description = "Module to interact with Tedee locks";
    homepage = "https://github.com/zweckj/aiotedee";
    changelog = "https://github.com/zweckj/aiotedee/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
