{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  jinja2,
  multidict,
  poetry-core,
  pydantic,
  pytestCheckHook,
  pyyaml,
  wtforms,
}:

buildPythonPackage rec {
  pname = "beanhub-forms";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "LaunchPlatform";
    repo = "beanhub-forms";
    tag = version;
    hash = "sha256-313c+ENmTe1LyfEiMXNB9AUoGx3Yv/1D0T3HnAbd+Zw=";
  };

  nativeCheckInputs = [
    multidict
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    jinja2
    pydantic
    pyyaml
    wtforms
  ];

  pyproject = true;
  pythonImportsCheck = [ "beanhub_forms" ];

  meta = {
    description = "Library for generating and processing BeanHub's custom forms";
    homepage = "https://github.com/LaunchPlatform/beanhub-forms/";
    changelog = "https://github.com/LaunchPlatform/beanhub-forms/releases/tag/${version}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fangpen ];
  };
}
