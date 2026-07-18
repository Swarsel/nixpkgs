{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  poetry-core,
  pytest-asyncio,
  pytestCheckHook,
  zeroconf,
}:

buildPythonPackage rec {
  pname = "altruistclient";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "LoSk-p";
    repo = "altruistclient";
    tag = version;
    hash = "sha256-36qqB9e53eZgMgwXzrXlMOySnuqmT3vLiU02NL9xtko=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    zeroconf
  ];

  pyproject = true;
  pythonImportsCheck = [ "altruistclient" ];

  meta = {
    description = "Async library for discovering and fetching data from Altruist sensors";
    homepage = "https://github.com/LoSk-p/altruistclient";
    changelog = "https://github.com/LoSk-p/altruistclient/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
