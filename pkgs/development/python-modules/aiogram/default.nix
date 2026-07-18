{
  lib,
  fetchFromGitHub,
  aiodns,
  aiofiles,
  aiohttp,
  aiohttp-socks,
  aresponses,
  babel,
  buildPythonPackage,
  certifi,
  cryptography,
  gitUpdater,
  hatchling,
  magic-filter,
  motor,
  pycryptodomex,
  pydantic,
  pymongo,
  pytest-aiohttp,
  pytest-asyncio,
  pytest-lazy-fixture,
  pytestCheckHook,
  pytz,
  redis,
  uvloop,
}:

buildPythonPackage rec {
  pname = "aiogram";
  version = "3.29.1";

  src = fetchFromGitHub {
    owner = "aiogram";
    repo = "aiogram";
    tag = "v${version}";
    hash = "sha256-Wn36YvuQ9geCAD0froVq2KulyeRWnc2AKX4FPCCKG8I=";
  };

  nativeCheckInputs = [
    aresponses
    pycryptodomex
    pytest-aiohttp
    pytest-asyncio
    pytest-lazy-fixture
    pytestCheckHook
    pytz
  ]
  ++ lib.concatAttrValues optional-dependencies;

  __darwinAllowLocalNetworking = true;
  build-system = [ hatchling ];

  dependencies = [
    aiofiles
    aiohttp
    certifi
    magic-filter
    pydantic
  ];

  optional-dependencies = {
    fast = [
      aiodns
      uvloop
    ];

    i18n = [ babel ];

    mongo = [
      motor
      pymongo
    ];

    proxy = [ aiohttp-socks ];
    redis = [ redis ];
    signature = [ cryptography ];
  };

  pyproject = true;

  pytestFlags = [
    # DeprecationWarning: 'asyncio.get_event_loop_policy' is deprecated and slate...
    "-Wignore::DeprecationWarning"
  ];

  pythonImportsCheck = [ "aiogram" ];
  pythonRelaxDeps = [ "aiohttp" ];

  passthru.updateScript = gitUpdater {
    ignoredVersions = "4.1";
    rev-prefix = "v";
  };

  meta = {
    description = "Modern and fully asynchronous framework for Telegram Bot API";
    homepage = "https://github.com/aiogram/aiogram";
    changelog = "https://github.com/aiogram/aiogram/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sikmir ];
  };
}
