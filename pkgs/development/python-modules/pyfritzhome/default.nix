{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyfritzhome";
  version = "0.6.20";

  src = fetchFromGitHub {
    owner = "hthiery";
    repo = "python-fritzhome";
    tag = finalAttrs.version;
    hash = "sha256-d79SS4zHsMD5aGuMNFnxwDV1IgU+0bwva/jUcfds9Hw=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    cryptography
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyfritzhome" ];

  meta = {
    description = "Python Library to access AVM FRITZ!Box homeautomation";
    homepage = "https://github.com/hthiery/python-fritzhome";
    changelog = "https://github.com/hthiery/python-fritzhome/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
    mainProgram = "fritzhome";
  };
})
