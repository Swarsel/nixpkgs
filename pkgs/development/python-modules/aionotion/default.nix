{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  buildPythonPackage,
  certifi,
  ciso8601,
  frozenlist,
  mashumaro,
  poetry-core,
  pyjwt,
  pytest-aiohttp,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  yarl,
}:

buildPythonPackage rec {
  pname = "aionotion";
  version = "2025.02.0";

  src = fetchFromGitHub {
    owner = "bachya";
    repo = "aionotion";
    tag = version;
    hash = "sha256-MqH3CPp+dAX5DXtnHio95KGQ+Ok2TXrX6rn/AMx5OsY=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "poetry-core==" "poetry-core>="
  '';

  nativeBuildInputs = [ poetry-core ];

  propagatedBuildInputs = [
    aiohttp
    certifi
    ciso8601
    frozenlist
    mashumaro
    pyjwt
    yarl
  ];

  nativeCheckInputs = [
    aresponses
    pytest-aiohttp
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  disabledTestPaths = [ "examples" ];
  pyproject = true;
  pythonImportsCheck = [ "aionotion" ];

  pythonRelaxDeps = [
    "ciso8601"
    "frozenlist"
    "mashumaro"
  ];

  meta = {
    description = "Python library for Notion Home Monitoring";
    homepage = "https://github.com/bachya/aionotion";
    changelog = "https://github.com/bachya/aionotion/releases/tag/${src.tag}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
