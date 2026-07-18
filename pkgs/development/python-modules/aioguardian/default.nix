{
  lib,
  fetchFromGitHub,
  aiohttp,
  asyncio-dgram,
  buildPythonPackage,
  certifi,
  frozenlist,
  poetry-core,
  pytest-aiohttp,
  pytest-asyncio,
  pytestCheckHook,
  typing-extensions,
  voluptuous,
  yarl,
}:

buildPythonPackage (finalAttrs: {
  pname = "aioguardian";
  version = "2026.01.1";

  src = fetchFromGitHub {
    owner = "bachya";
    repo = "aioguardian";
    tag = finalAttrs.version;
    hash = "sha256-55jMGJ4pRMjvSAYsXIclzzMcz+PqS/334Fd7hoY8YTk=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail poetry-core==2.0.1 poetry-core
  '';

  nativeCheckInputs = [
    asyncio-dgram
    pytest-aiohttp
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    asyncio-dgram
    certifi
    frozenlist
    voluptuous
    typing-extensions
    yarl
  ];

  disabledTestPaths = [ "examples/" ];
  pyproject = true;
  pythonImportsCheck = [ "aioguardian" ];

  pythonRelaxDeps = [
    "asyncio_dgram"
    "frozenlist"
    "typing-extensions"
  ];

  meta = {
    description = "Python library to interact with Elexa Guardian devices";

    longDescription = ''
      aioguardian is an asyncio-focused library for interacting with the
      Guardian line of water valves and sensors from Elexa.
    '';

    homepage = "https://github.com/bachya/aioguardian";
    changelog = "https://github.com/bachya/aioguardian/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
