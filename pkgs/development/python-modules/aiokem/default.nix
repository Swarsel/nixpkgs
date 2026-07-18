{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pyjwt,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  pythonOlder,
  setuptools,
  syrupy,
}:

buildPythonPackage rec {
  pname = "aiokem";
  version = "1.1.4";

  src = fetchFromGitHub {
    owner = "kohlerlibs";
    repo = "aiokem";
    tag = "v${version}";
    hash = "sha256-4LbpTov81LMr4V8jMgttlUCyHWJoR6tExOvt8X4Telc=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
    syrupy
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    pyjwt
  ];

  disabled = pythonOlder "3.12";
  pyproject = true;
  pythonImportsCheck = [ "aiokem" ];

  meta = {
    description = "Async API for Kohler Energy Management";
    homepage = "https://github.com/kohlerlibs/aiokem";
    changelog = "https://github.com/kohlerlibs/aiokem/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
