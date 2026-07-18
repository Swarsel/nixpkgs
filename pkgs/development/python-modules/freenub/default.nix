{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  busypie,
  cbor2,
  poetry-core,
  pycryptodomex,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-vcr,
  pytestCheckHook,
  requests,
}:

buildPythonPackage rec {
  pname = "freenub";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "bdraco";
    repo = "freenub";
    tag = "v${version}";
    hash = "sha256-UkW/7KUQ4uCu3cxDSL+kw0gjKjs4KnmxRIOLVP4hwyA=";
  };

  nativeCheckInputs = [
    busypie
    pytest-asyncio
    pytest-cov-stub
    pytest-vcr
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    cbor2
    pycryptodomex
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "pubnub" ];

  meta = {
    description = "Fork of pubnub";
    homepage = "https://github.com/bdraco/freenub";
    changelog = "https://github.com/bdraco/freenub/blob/${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
