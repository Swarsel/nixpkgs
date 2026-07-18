{
  lib,
  fetchFromGitHub,
  aiohttp,
  bitstruct,
  buildPythonPackage,
  cryptography,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  typing-extensions,
  voluptuous,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-otbr-api";
  version = "2.10.0";

  src = fetchFromGitHub {
    owner = "home-assistant-libs";
    repo = "python-otbr-api";
    tag = finalAttrs.version;
    hash = "sha256-WBL6R4yw/4yuF/T94NtaapGspn4L2H0glVatW6+hoRk=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    bitstruct
    cryptography
    typing-extensions
    voluptuous
  ];

  pyproject = true;
  pythonImportsCheck = [ "python_otbr_api" ];

  meta = {
    description = "Library for the Open Thread Border Router";
    homepage = "https://github.com/home-assistant-libs/python-otbr-api";
    changelog = "https://github.com/home-assistant-libs/python-otbr-api/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
