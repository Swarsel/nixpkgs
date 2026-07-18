{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "typing-inspection";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "pydantic";
    repo = "typing-inspection";
    tag = "v${version}";
    hash = "sha256-aGScO+FLEJ5IyI6hBqdsiKJRN7vEG36V5131nhVZEbc=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "typing_inspection" ];

  meta = {
    description = "Runtime typing introspection tools";
    homepage = "https://github.com/pydantic/typing-inspection";
    changelog = "https://github.com/pydantic/typing-inspection/blob/${src.tag}/HISTORY.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
