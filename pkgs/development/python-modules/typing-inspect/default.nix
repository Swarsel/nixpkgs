{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mypy-extensions,
  pytestCheckHook,
  setuptools,
  typing-extensions,
}:

buildPythonPackage {
  pname = "typing-inspect";
  version = "0.9.0-unstable-2025-10-20";

  src = fetchFromGitHub {
    owner = "ilevkivskyi";
    repo = "typing_inspect";
    rev = "58c98c084ebeb45ee51935506ed1cc3449105fa9";
    hash = "sha256-uGGtV32TGckoM3JALNu2OjIE+gmzJc7VMJlQeKJVFd8=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    typing-extensions
    mypy-extensions
  ];

  format = "setuptools";
  pythonImportsCheck = [ "typing_inspect" ];

  meta = {
    description = "Runtime inspection utilities for Python typing module";
    homepage = "https://github.com/ilevkivskyi/typing_inspect";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ albakham ];
  };
}
