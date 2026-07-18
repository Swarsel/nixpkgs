{
  lib,
  fetchFromGitHub,
  aiolimiter,
  apscheduler,
  beautifulsoup4,
  buildPythonPackage,
  cachetools,
  cffi,
  cryptography,
  flaky,
  hatchling,
  httpx,
  pytest-asyncio,
  pytest-timeout,
  pytest-xdist,
  pytestCheckHook,
  pythonAtLeast,
  pytz,
  setuptools,
  tornado,
}:

buildPythonPackage rec {
  pname = "python-telegram-bot";
  version = "22.7";

  src = fetchFromGitHub {
    owner = "python-telegram-bot";
    repo = "python-telegram-bot";
    tag = "v${version}";
    hash = "sha256-+mbVN1XFChUMYReHMjQd1tx5gYpP1CWGNtuZCoY9TMo=";
  };

  nativeCheckInputs = [
    beautifulsoup4
    flaky
    pytest-asyncio
    pytest-timeout
    pytest-xdist
    pytestCheckHook
  ]
  ++ optional-dependencies.all;

  build-system = [
    setuptools
    hatchling
  ];

  dependencies = [ httpx ];

  disabledTests = [
    # Tests require network access
    "TestAIO"
    "TestAnimation"
    "TestApplication"
    "TestAudio"
    "TestBase"
    "TestBot"
    "TestCallback"
    "TestChat"
    "TestChosenInlineResult"
    "TestCommandHandler"
    "TestConstants"
    "TestContact"
    "TestConversationHandler"
    "TestDice"
    "TestDict"
    "TestDocument"
    "TestFile"
    "TestForceReply"
    "TestForum"
    "TestGame"
    "TestGet"
    "TestGiftsWithRequest"
    "TestHTTP"
    "TestInline"
    "TestInput"
    "TestInvoice"
    "TestJob"
    "TestKeyboard"
    "TestLocation"
    "TestMask"
    "TestMenu"
    "TestMessage"
    "TestMeta"
    "TestOrder"
    "TestPassport"
    "TestPhoto"
    "TestPickle"
    "TestPoll"
    "TestPre"
    "TestPrefix"
    "TestProximity"
    "TestReply"
    "TestRequest"
    "TestSend"
    "TestSent"
    "TestShipping"
    "TestSlot"
    "TestSticker"
    "TestString"
    "TestSuccess"
    "TestTelegram"
    "TestType"
    "TestUpdate"
    "TestUser"
    "TestVenue"
    "TestVideo"
    "TestVoice"
    "TestWeb"
  ];

  optional-dependencies = rec {
    all = ext ++ http2 ++ passport ++ socks;
    callback-data = [ cachetools ];
    ext = callback-data ++ job-queue ++ rate-limiter ++ webhooks;
    http2 = httpx.optional-dependencies.http2;

    job-queue = [
      apscheduler
      pytz
    ];

    passport = [ cryptography ] ++ lib.optionals (pythonAtLeast "3.13") [ cffi ];
    rate-limiter = [ aiolimiter ];
    socks = httpx.optional-dependencies.socks;
    webhooks = [ tornado ];
  };

  pyproject = true;
  pythonImportsCheck = [ "telegram" ];

  meta = {
    description = "Python library to interface with the Telegram Bot API";
    homepage = "https://python-telegram-bot.org";
    changelog = "https://github.com/python-telegram-bot/python-telegram-bot/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.lgpl3Only;

    maintainers = with lib.maintainers; [
      veprbl
      pingiun
    ];
  };
}
