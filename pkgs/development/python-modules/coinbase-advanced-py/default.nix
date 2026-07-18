{
  lib,
  fetchFromGitHub,
  backoff,
  buildPythonPackage,
  cryptography,
  pyjwt,
  pytestCheckHook,
  pythonRelaxDepsHook,
  requests,
  requests-mock,
  setuptools,
  websockets,
}:

buildPythonPackage rec {
  pname = "coinbase-advanced-py";
  version = "1.8.4";

  src = fetchFromGitHub {
    owner = "coinbase";
    repo = "coinbase-advanced-py";
    tag = "v${version}";
    hash = "sha256-kr2S6oB5H/SpmZgcK+dAJyMijp5OdxLszTbc6yAcX6I=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    requests-mock
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    requests
    cryptography
    pyjwt
    websockets
    backoff
  ];

  disabledTestPaths = [
    # WebSocket tests fail due to API changes in websockets >= 14.0
    "tests/websocket/"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "coinbase"
    "coinbase.rest"
    "coinbase.websocket"
  ];

  pythonRelaxDeps = [
    "websockets"
  ];

  meta = {
    description = "Coinbase Advanced API Python SDK";
    homepage = "https://github.com/coinbase/coinbase-advanced-py";
    changelog = "https://github.com/coinbase/coinbase-advanced-py/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
