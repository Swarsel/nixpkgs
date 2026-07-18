{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  poetry-core,
  pytest-cov-stub,
  pytestCheckHook,
  xmltodict,
}:

buildPythonPackage rec {
  pname = "aiosteamist";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "bdraco";
    repo = "aiosteamist";
    tag = "v${version}";
    hash = "sha256-e7Nt/o2A1qn2nSpWv6ZsZHn/WpcXKzol+f+JNJaSb4w=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    xmltodict
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiosteamist" ];

  meta = {
    description = "Module to control Steamist steam systems";
    homepage = "https://github.com/bdraco/aiosteamist";
    changelog = "https://github.com/bdraco/aiosteamist/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
