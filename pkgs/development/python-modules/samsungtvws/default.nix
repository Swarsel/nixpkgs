{
  lib,
  fetchFromGitHub,
  # extras: async
  aiohttp,
  # tests
  aioresponses,
  buildPythonPackage,
  # extras: encrypted
  cryptography,
  py3rijndael,
  pytest-asyncio,
  pytestCheckHook,
  # propagates:
  requests,
  # build system
  setuptools,
  websocket-client,
  websockets,
}:

buildPythonPackage rec {
  pname = "samsungtvws";
  version = "3.0.5";

  src = fetchFromGitHub {
    owner = "xchwarze";
    repo = "samsung-tv-ws-api";
    tag = "v${version}";
    hash = "sha256-8DDxon6ZGP0dToYxa2ZkvKl+1aFpvS1Zs+w7Hsozwdw=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytestCheckHook
  ]
  ++ optional-dependencies.async
  ++ optional-dependencies.encrypted;

  build-system = [ setuptools ];

  dependencies = [
    requests
    websocket-client
  ];

  optional-dependencies = {
    async = [
      aiohttp
      websockets
    ];

    encrypted = [
      cryptography
      py3rijndael
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "samsungtvws" ];

  meta = {
    description = "Samsung Smart TV WS API wrapper";
    homepage = "https://github.com/xchwarze/samsung-tv-ws-api";
    changelog = "https://github.com/xchwarze/samsung-tv-ws-api/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
