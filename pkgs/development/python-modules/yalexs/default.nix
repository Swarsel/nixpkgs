{
  lib,
  fetchFromGitHub,
  aiofiles,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  ciso8601,
  freenub,
  poetry-core,
  propcache,
  pyjwt,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-freezegun,
  pytestCheckHook,
  python-dateutil,
  python-socketio,
  requests,
  requests-mock,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "yalexs";
  version = "9.2.7";

  src = fetchFromGitHub {
    owner = "bdraco";
    repo = "yalexs";
    tag = "v${version}";
    hash = "sha256-HZN3ot5z/JbWZaWLffyTWLneD1gG3tTdYLKevXYnJnw=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytest-cov-stub
    pytest-freezegun
    pytestCheckHook
    requests-mock
  ];

  build-system = [ poetry-core ];

  dependencies = [
    aiofiles
    aiohttp
    ciso8601
    freenub
    propcache
    pyjwt
    python-dateutil
    python-socketio
    requests
    typing-extensions
  ]
  ++ python-socketio.optional-dependencies.asyncio_client;

  disabledTests = [
    # aiohttp api breakage, remove when bumping to 9.2.8 or newer
    "test__raise_response_exceptions"
  ];

  pyproject = true;
  pythonImportsCheck = [ "yalexs" ];
  pythonRelaxDeps = [ "aiohttp" ];

  meta = {
    description = "Python API for Yale Access (formerly August) Smart Lock and Doorbell";
    homepage = "https://github.com/bdraco/yalexs";
    changelog = "https://github.com/bdraco/yalexs/blob/${src.tag}/CHANGELOG.md";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
