{
  lib,
  fetchFromGitHub,
  aiosmtplib,
  blinker,
  buildPythonPackage,
  cryptography,
  email-validator,
  fakeredis,
  httpx,
  jinja2,
  poetry-core,
  pydantic,
  pydantic-settings,
  pytest-asyncio,
  pytestCheckHook,
  redis,
  regex,
  starlette,
}:

buildPythonPackage (finalAttrs: {
  pname = "fastapi-mail";
  version = "1.6.2";

  src = fetchFromGitHub {
    owner = "sabuhish";
    repo = "fastapi-mail";
    tag = "v${finalAttrs.version}";
    hash = "sha256-oWm2FvXCyz+0QRvClcJoKF17rWggAtQasa5h1pZ6N4Y=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    aiosmtplib
    blinker
    cryptography
    email-validator
    fakeredis
    jinja2
    pydantic
    pydantic-settings
    regex
    starlette
  ];

  disabledTests = [
    # Tests require access to /etc/resolv.conf
    "test_default_checker"
    "test_redis_checker"
    "test_local_hostname_resolving"
  ];

  optional-dependencies = {
    httpx = [ httpx ];
    redis = [ redis ];
  };

  pyproject = true;
  pythonImportsCheck = [ "fastapi_mail" ];

  pythonRelaxDeps = [
    "aiosmtplib"
    "cryptography"
    "email-validator"
    "regex"
    "pydantic"
  ];

  meta = {
    description = "Module for sending emails and attachments";
    homepage = "https://github.com/sabuhish/fastapi-mail";
    changelog = "https://github.com/sabuhish/fastapi-mail/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
