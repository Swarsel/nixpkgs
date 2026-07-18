{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  hatch-vcs,
  hatchling,
  pytestCheckHook,
  requests,
}:

buildPythonPackage (finalAttrs: {
  pname = "http-message-signatures";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "pyauth";
    repo = "http-message-signatures";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GFOdefqcAia4ZHqt1XMS2dw2bQ3AzbY0AQm7b8niYRI=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    requests
  ];

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [ cryptography ];
  enabledTestPaths = [ "test/test.py" ];
  pyproject = true;
  pythonImportsCheck = [ "http_message_signatures" ];

  meta = {
    description = "Requests authentication module for HTTP Signature";
    homepage = "https://github.com/pyauth/http-message-signatures";
    changelog = "https://github.com/pyauth/http-message-signatures/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
