{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  freezegun,
  openccu-data,
  orjson,
  pydantic,
  pydevccu,
  pytest-asyncio,
  pytest-socket,
  pytest-xdist,
  pytestCheckHook,
  python-slugify,
  pythonOlder,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "aiohomematic";
  version = "2026.7.6";

  src = fetchFromGitHub {
    owner = "SukramJ";
    repo = "aiohomematic";
    tag = finalAttrs.version;
    hash = "sha256-dshlAmjzv13Q9AijApEDNvhI3jLzDMLBs8KDtElzqJ4=";
  };

  nativeCheckInputs = [
    freezegun
    pydevccu
    pytest-asyncio
    pytest-xdist
    pytest-socket
    pytestCheckHook
  ];

  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    openccu-data
    orjson
    pydantic
    python-slugify
  ];

  disabled = pythonOlder "3.14";
  pyproject = true;
  pythonImportsCheck = [ "aiohomematic" ];

  meta = {
    description = "Module to interact with HomeMatic devices";
    homepage = "https://github.com/SukramJ/aiohomematic";
    changelog = "https://github.com/SukramJ/aiohomematic/blob/${finalAttrs.src.tag}/changelog.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      dotlambda
      fab
    ];
  };
})
