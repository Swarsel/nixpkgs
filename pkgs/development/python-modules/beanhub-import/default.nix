{
  lib,
  fetchFromGitHub,
  beancount-black,
  beancount-parser,
  beanhub-extract,
  buildPythonPackage,
  hatchling,
  jinja2,
  pydantic,
  pytestCheckHook,
  pytz,
  pyyaml,
}:

buildPythonPackage rec {
  pname = "beanhub-import";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "LaunchPlatform";
    repo = "beanhub-import";
    tag = version;
    hash = "sha256-0Or83zod1RIx7Dm+3+EuyV8gP4Ip3ziOuS2if0ThzAQ=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];

  dependencies = [
    beancount-black
    beancount-parser
    beanhub-extract
    jinja2
    pydantic
    pytz
    pyyaml
  ];

  pyproject = true;
  pythonImportsCheck = [ "beanhub_import" ];

  pythonRelaxDeps = [
    # pytz>=2023.1,<2025, but we have 2025.1
    "pytz"
  ];

  meta = {
    description = "Declarative idempotent rule-based Beancount transaction import engine in Python";
    homepage = "https://github.com/LaunchPlatform/beanhub-import/";
    changelog = "https://github.com/LaunchPlatform/beanhub-import/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fangpen ];
  };
}
