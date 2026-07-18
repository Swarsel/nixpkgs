{
  lib,
  fetchFromGitHub,
  aiohttp,
  aiomqtt,
  buildPythonPackage,
  freezegun,
  poetry-core,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "letpot";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "jpelgrom";
    repo = "python-letpot";
    tag = "v${finalAttrs.version}";
    hash = "sha256-w4WS0AyNd4dNtA/fBKieDW2YXwBFltRkJvaGemRjsv4=";
  };

  nativeCheckInputs = [
    freezegun
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    aiomqtt
  ];

  pyproject = true;
  pythonImportsCheck = [ "letpot" ];

  meta = {
    description = "Asynchronous Python client for LetPot hydroponic gardens";
    homepage = "https://github.com/jpelgrom/python-letpot";
    changelog = "https://github.com/jpelgrom/python-letpot/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
