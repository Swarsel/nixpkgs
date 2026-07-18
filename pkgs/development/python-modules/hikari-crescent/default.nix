{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  croniter,
  hikari,
  poetry-core,
  pynacl,
  pytest-asyncio,
  pytestCheckHook,
  python-dotenv,
  sigparse,
}:

buildPythonPackage (finalAttrs: {
  pname = "hikari-crescent";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "hikari-crescent";
    repo = "hikari-crescent";
    tag = "v${finalAttrs.version}";
    hash = "sha256-86NCAlN5/JGrxPVIMs6ARr6H4G3shPcgxASwukptyJo=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    python-dotenv
    pytest-asyncio
    croniter
    pynacl
  ];

  build-system = [ poetry-core ];

  dependencies = [
    hikari
    sigparse
  ];

  disabledTestPaths = [ "tests/test_bot/test_bot.py" ];
  disabledTests = [ "test_handle_resp" ];
  pyproject = true;
  pythonImportsCheck = [ "crescent" ];

  meta = {
    description = "Command handler for Hikari that keeps your project neat and tidy";
    homepage = "https://github.com/hikari-crescent/hikari-crescent";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
    mainProgram = "hikari-crescent";
  };
})
