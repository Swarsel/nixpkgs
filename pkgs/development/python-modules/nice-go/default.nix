{
  lib,
  fetchFromGitHub,
  aiobotocore,
  aiohttp,
  buildPythonPackage,
  poetry-core,
  pycognito,
  pytest-aiohttp,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  syrupy,
  tenacity,
  yarl,
}:

buildPythonPackage rec {
  pname = "nice-go";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "IceBotYT";
    repo = "nice-go";
    tag = version;
    hash = "sha256-09Tc2fFXUevQNgJmXyeXy1sBg9Cr9OV/15Feh9tlRug=";
  };

  nativeCheckInputs = [
    pytest-aiohttp
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
    syrupy
  ];

  build-system = [ poetry-core ];

  dependencies = [
    aiobotocore
    aiohttp
    pycognito
    tenacity
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "nice_go" ];

  pythonRelaxDeps = [
    "aiobotocore"
    "tenacity"
  ];

  meta = {
    description = "Control various Nice access control products";
    homepage = "https://github.com/IceBotYT/nice-go";
    changelog = "https://github.com/IceBotYT/nice-go/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
