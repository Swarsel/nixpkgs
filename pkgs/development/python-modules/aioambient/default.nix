{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  buildPythonPackage,
  certifi,
  poetry-core,
  pytest-aiohttp,
  pytest-asyncio,
  pytestCheckHook,
  python-engineio,
  python-socketio,
  websockets,
  yarl,
}:

buildPythonPackage rec {
  pname = "aioambient";
  version = "2025.02.0";

  src = fetchFromGitHub {
    owner = "bachya";
    repo = "aioambient";
    tag = version;
    hash = "sha256-F1c2S0c/CWHeCd24Zc8ib3aPR7yj9gCPBJpmpgoddQY=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail poetry-core==2.0.1 poetry-core
  '';

  nativeCheckInputs = [
    aresponses
    pytest-aiohttp
    pytest-asyncio
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    certifi
    python-engineio
    python-socketio
    websockets
    yarl
  ];

  # Ignore the examples directory as the files are prefixed with test_
  disabledTestPaths = [ "examples/" ];
  pyproject = true;
  pythonImportsCheck = [ "aioambient" ];

  meta = {
    description = "Python library for the Ambient Weather API";
    homepage = "https://github.com/bachya/aioambient";
    changelog = "https://github.com/bachya/aioambient/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
