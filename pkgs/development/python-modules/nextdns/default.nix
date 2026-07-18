{
  lib,
  fetchFromGitHub,
  aiohttp,
  aiointercept,
  aioresponses,
  buildPythonPackage,
  pytest-asyncio,
  pytest-error-for-skips,
  pytestCheckHook,
  setuptools,
  syrupy,
  tenacity,
}:

buildPythonPackage (finalAttrs: {
  pname = "nextdns";
  version = "5.0.1";

  src = fetchFromGitHub {
    owner = "bieniu";
    repo = "nextdns";
    tag = finalAttrs.version;
    hash = "sha256-QCiosQHxuwDxztXMEkEosob8M2NMtnlGI33m5oAkaBw=";
  };

  nativeCheckInputs = [
    aiointercept
    aioresponses
    pytest-asyncio
    pytest-error-for-skips
    pytestCheckHook
    syrupy
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    tenacity
  ];

  pyproject = true;
  pythonImportsCheck = [ "nextdns" ];
  pythonRelaxDeps = [ "aiohttp" ];

  meta = {
    description = "Module for the NextDNS API";
    homepage = "https://github.com/bieniu/nextdns";
    changelog = "https://github.com/bieniu/nextdns/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
