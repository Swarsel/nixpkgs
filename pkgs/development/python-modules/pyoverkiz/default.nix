{
  lib,
  fetchFromGitHub,
  aiohttp,
  attrs,
  backoff,
  boto3,
  buildPythonPackage,
  cattrs,
  hatchling,
  pytest-asyncio,
  pytestCheckHook,
  warrant-lite,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyoverkiz";
  version = "2.0.5";

  src = fetchFromGitHub {
    owner = "iMicknl";
    repo = "python-overkiz-api";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LdOVhOWxejTXhgUwlbucYNDqhKJDov56IaEcvJvEBQ4=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    attrs
    backoff
    cattrs
  ];

  optional-dependencies = {
    nexity = [
      boto3
      warrant-lite
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pyoverkiz" ];

  meta = {
    description = "Module to interact with the Somfy TaHoma API or other OverKiz APIs";
    homepage = "https://github.com/iMicknl/python-overkiz-api";
    changelog = "https://github.com/iMicknl/python-overkiz-api/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
