{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  httpx,
  poetry-core,
  pytest-asyncio,
  pytest-httpx,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "luftdaten";
  version = "0.7.5";

  src = fetchFromGitHub {
    owner = "home-assistant-ecosystem";
    repo = "python-luftdaten";
    tag = finalAttrs.version;
    hash = "sha256-KZ89ufU7wWPFp1zthmao/cSFbUDWlJY4iBNQ19fgIBQ=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-httpx
    pytestCheckHook
  ];

  build-system = [ poetry-core ];
  dependencies = [ httpx ];
  pyproject = true;
  pythonImportsCheck = [ "luftdaten" ];

  meta = {
    description = "Python API for interacting with luftdaten.info";
    homepage = "https://github.com/home-assistant-ecosystem/python-luftdaten";
    changelog = "https://github.com/home-assistant-ecosystem/python-luftdaten/blob/${finalAttrs.src.tag}/CHANGES.rst";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      dotlambda
      fab
    ];
  };
})
