{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  poetry-core,
  pycryptodome,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-freezer,
  pytestCheckHook,
  syrupy,
}:

buildPythonPackage (finalAttrs: {
  pname = "switchbot-api";
  version = "2.12.0";

  src = fetchFromGitHub {
    owner = "SeraphicCorp";
    repo = "py-switchbot-api";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mvGWuj+YpAqMg8dpICMwkY73vVwrvF6Klld2h2q1Mig=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytest-cov-stub
    pytest-freezer
    pytestCheckHook
    syrupy
  ];

  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    pycryptodome
  ];

  pyproject = true;
  pythonImportsCheck = [ "switchbot_api" ];

  meta = {
    description = "Asynchronous library to use Switchbot API";
    homepage = "https://github.com/SeraphicCorp/py-switchbot-api";
    changelog = "https://github.com/SeraphicCorp/py-switchbot-api/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
