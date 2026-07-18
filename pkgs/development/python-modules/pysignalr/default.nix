{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  docker,
  hatchling,
  msgpack,
  orjson,
  pytest-asyncio,
  pytestCheckHook,
  requests,
  websockets,
}:

buildPythonPackage rec {
  pname = "pysignalr";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "baking-bad";
    repo = "pysignalr";
    tag = version;
    hash = "sha256-/Wa2ZeIuvF/4hM79N0rL0DxrBV60BM8/4uvV6ma79Xk=";
  };

  nativeCheckInputs = [
    docker
    pytest-asyncio
    pytestCheckHook
    requests
  ];

  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    msgpack
    orjson
    websockets
  ];

  pyproject = true;
  pythonImportsCheck = [ "pysignalr" ];
  pythonRelaxDeps = [ "websockets" ];

  meta = {
    description = "Modern, reliable and async-ready client for SignalR protocol";
    homepage = "https://github.com/baking-bad/pysignalr";
    changelog = "https://github.com/baking-bad/pysignalr/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
