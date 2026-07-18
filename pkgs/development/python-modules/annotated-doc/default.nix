{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pdm-backend,
  pytestCheckHook,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "annotated-doc";
  version = "0.0.4";

  src = fetchFromGitHub {
    owner = "fastapi";
    repo = "annotated-doc";
    tag = version;
    hash = "sha256-O7kobzzFfHelYsxTflifEcoEWsUmPzlDz3siFTAq0I0=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    typing-extensions
  ];

  build-system = [
    pdm-backend
  ];

  pyproject = true;

  pythonImportsCheck = [
    "annotated_doc"
  ];

  meta = {
    description = "Document parameters, class attributes, return types, and variables inline, with Annotated";
    homepage = "https://github.com/fastapi/annotated-doc";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
