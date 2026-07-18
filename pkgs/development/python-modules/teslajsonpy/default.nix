{
  lib,
  fetchFromGitHub,
  aiohttp,
  authcaptureproxy,
  backoff,
  beautifulsoup4,
  buildPythonPackage,
  httpx,
  orjson,
  poetry-core,
  pytest-asyncio,
  pytestCheckHook,
  tenacity,
  wrapt,
}:

buildPythonPackage rec {
  pname = "teslajsonpy";
  version = "3.13.2";

  src = fetchFromGitHub {
    owner = "zabuldon";
    repo = "teslajsonpy";
    tag = "v${version}";
    hash = "sha256-tlw5m8RsBGwVx3h+JlY9rwINMDR6csAt2XefK6AaQWE=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    authcaptureproxy
    aiohttp
    backoff
    beautifulsoup4
    httpx
    orjson
    tenacity
    wrapt
  ];

  pyproject = true;
  pythonImportsCheck = [ "teslajsonpy" ];

  meta = {
    description = "Python library to work with Tesla API";
    homepage = "https://github.com/zabuldon/teslajsonpy";
    changelog = "https://github.com/zabuldon/teslajsonpy/releases/tag/${src.tag}";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
