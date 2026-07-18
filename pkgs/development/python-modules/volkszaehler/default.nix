{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  hatchling,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "volkszaehler";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "home-assistant-ecosystem";
    repo = "python-volkszaehler";
    tag = finalAttrs.version;
    hash = "sha256-DgsP3ol6VcOnoUJF1eQjNWR45SokElNosyfgvPZVihU=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ hatchling ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "volkszaehler" ];

  meta = {
    description = "Python module for interacting with the Volkszahler API";
    homepage = "https://github.com/home-assistant-ecosystem/python-volkszaehler";
    changelog = "https://github.com/home-assistant-ecosystem/python-volkszaehler/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
