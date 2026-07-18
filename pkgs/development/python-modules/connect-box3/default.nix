{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cyclopts,
  hatchling,
  httpx,
  mashumaro,
  pytest-asyncio,
  pytest-httpx,
  pytestCheckHook,
  rich,
}:

buildPythonPackage (finalAttrs: {
  pname = "connect-box3";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "home-assistant-ecosystem";
    repo = "python-connect-box3";
    tag = finalAttrs.version;
    hash = "sha256-eLrCMziV/+maLIded1n0248Xb14uVBps/gzTUz8NMMc=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pytest-httpx
  ];

  build-system = [ hatchling ];

  dependencies = [
    cyclopts
    httpx
    mashumaro
    rich
  ];

  pyproject = true;
  pythonImportsCheck = [ "connect_box3" ];

  meta = {
    description = "Interact with a Connect Box 3 modem/router";
    homepage = "https://github.com/home-assistant-ecosystem/python-connect-box3";
    changelog = "https://github.com/home-assistant-ecosystem/python-connect-box3/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "connect-box";
  };
})
