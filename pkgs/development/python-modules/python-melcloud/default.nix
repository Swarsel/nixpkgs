{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  mashumaro,
  orjson,
  poetry-core,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  yarl,
}:

buildPythonPackage rec {
  pname = "python-melcloud";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "erwindouna";
    repo = "python-melcloud";
    tag = version;
    hash = "sha256-i0/Ra5V3W/TOW+wRZZfKXuGtJTJeHqs+tPuS6KBZasE=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "poetry-core>=1.5,<2.0" poetry-core
  '';

  nativeCheckInputs = [
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
  ];

  pyproject = true;
  pythonImportsCheck = [ "pymelcloud" ];

  pythonRemoveDeps = [
    "aioresponses"
    "mashumaro"
    "orjson"
    "yarl"
  ];

  meta = {
    description = "Asynchronous Python client for controlling Melcloud devices";
    homepage = "https://github.com/erwindouna/python-melcloud";
    changelog = "https://github.com/erwindouna/python-melcloud/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
