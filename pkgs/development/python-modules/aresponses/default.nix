{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pytest-asyncio_0,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "aresponses";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "aresponses";
    repo = "aresponses";
    rev = version;
    hash = "sha256-RklXlIsbdq46/7D6Hv4mdskunqw1a7SFF09OjhrvMRY=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    pytest-asyncio_0
  ];

  disabledTests = [
    # Disable tests which requires network access
    "test_foo"
    "test_passthrough"
  ];

  pyproject = true;
  pythonImportsCheck = [ "aresponses" ];

  meta = {
    description = "Asyncio testing server";
    homepage = "https://github.com/aresponses/aresponses";
    changelog = "https://github.com/aresponses/aresponses/blob/${src.rev}/README.md#changelog";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ makefu ];
  };
}
