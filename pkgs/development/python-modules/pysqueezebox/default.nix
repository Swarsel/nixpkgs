{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pysqueezebox";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "rajlaud";
    repo = "pysqueezebox";
    tag = "v${version}";
    hash = "sha256-aJKUgFTAfBZzzhtzklzOCgknk4Yk2i8YPqeVR6/444Q=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
  ];

  disabledTestPaths = [
    # Tests require network access
    "tests/test_integration.py"
  ];

  disabledTests = [
    # Test contacts 192.168.1.1
    "test_bad_response"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pysqueezebox" ];

  meta = {
    description = "Asynchronous library to control Logitech Media Server";
    homepage = "https://github.com/rajlaud/pysqueezebox";
    changelog = "https://github.com/rajlaud/pysqueezebox/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nyanloutre ];
  };
}
