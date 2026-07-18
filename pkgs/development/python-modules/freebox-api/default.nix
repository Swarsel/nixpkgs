{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  poetry-core,
  pytestCheckHook,
  urllib3,
}:

buildPythonPackage (finalAttrs: {
  pname = "freebox-api";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "hacf-fr";
    repo = "freebox-api";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3M29mboTZMG9lZSt816PvAXzl2DaqiC2nhikcpn+gqU=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    urllib3
  ];

  pyproject = true;
  pythonImportsCheck = [ "freebox_api" ];
  pythonRelaxDeps = [ "urllib3" ];

  meta = {
    description = "Python module to interact with the Freebox OS API";
    homepage = "https://github.com/hacf-fr/freebox-api";
    changelog = "https://github.com/hacf-fr/freebox-api/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "freebox_api";
  };
})
