{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioredis,
  buildPythonPackage,
  coloredlogs,
  fastapi,
  hatchling,
  pillow,
  psutil,
  pytestCheckHook,
  redis,
  requests,
  ujson,
  uvicorn,
  watchdog,
}:

buildPythonPackage (finalAttrs: {
  pname = "pytelegrambotapi";
  version = "4.33.0";

  src = fetchFromGitHub {
    owner = "eternnoir";
    repo = "pyTelegramBotAPI";
    tag = finalAttrs.version;
    hash = "sha256-za2krpb8Gll0zjuVFgQApDeROI7YSYo4fG6pi2hdv3g=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    requests
  ]
  ++ lib.flatten (builtins.attrValues finalAttrs.passthru.optional-dependencies);

  build-system = [ hatchling ];

  optional-dependencies = {
    PIL = [ pillow ];
    aiohttp = [ aiohttp ];
    aioredis = [ aioredis ];
    coloredlogs = [ coloredlogs ];
    fastapi = [ fastapi ];
    json = [ ujson ];
    psutil = [ psutil ];
    redis = [ redis ];
    uvicorn = [ uvicorn ];
    watchdog = [ watchdog ];
  };

  pyproject = true;
  pythonImportsCheck = [ "telebot" ];

  meta = {
    description = "Python implementation for the Telegram Bot API";
    homepage = "https://github.com/eternnoir/pyTelegramBotAPI";
    changelog = "https://github.com/eternnoir/pyTelegramBotAPI/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ das_j ];
  };
})
