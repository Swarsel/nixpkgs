{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  email-validator,
  hatchling,
  jinja2,
  lxml,
  ollama,
  pydantic,
  pytest-dotenv,
  pytest-factoryboy,
  pytest-mock,
  pytestCheckHook,
  pyyaml,
}:

buildPythonPackage rec {
  pname = "beanhub-inbox";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "LaunchPlatform";
    repo = "beanhub-inbox";
    tag = version;
    hash = "sha256-WWfZsJRm2rJI85vmFt/AtV++5vpSTJZpRrk3PdHMhAA=";
  };

  nativeCheckInputs = [
    pytest-dotenv
    pytest-factoryboy
    pytest-mock
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    email-validator
    jinja2
    lxml
    ollama
    pydantic
    pyyaml
  ];

  pyproject = true;
  pythonImportsCheck = [ "beanhub_inbox" ];

  meta = {
    description = "Email processing engine for archiving and extracting financial data with LLM";
    homepage = "https://github.com/LaunchPlatform/beanhub-inbox";
    changelog = "https://github.com/LaunchPlatform/beanhub-inbox/releases/tag${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
