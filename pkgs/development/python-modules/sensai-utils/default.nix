{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "sensai-utils";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "opcode81";
    repo = "sensAI-utils";
    tag = "v${version}";
    hash = "sha256-E/9pCkSvKeGW1wlO6+YD0glbPrt4aJ7NZ0Kss2VbGdE=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ typing-extensions ];
  pyproject = true;
  pythonImportsCheck = [ "sensai.util" ];

  meta = {
    description = "Utilities from sensAI, the Python library for sensible AI";
    homepage = "https://github.com/opcode81/sensAI-utils";
    changelog = "https://github.com/opcode81/sensAI-utils/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ derdennisop ];
  };
}
