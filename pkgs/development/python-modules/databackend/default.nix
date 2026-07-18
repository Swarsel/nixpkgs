{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pip-tools,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "databackend";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "machow";
    repo = "databackend";
    tag = "v${version}";
    hash = "sha256-M5Nm33Vae6FDy4aurru4CeHjeNxyZZnqzpdkqNEvrm0=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pip-tools
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "databackend" ];

  meta = {
    description = "Module to register a subclass, without needing to import the subclass itself";
    homepage = "https://github.com/machow/databackend";
    changelog = "https://github.com/machow/databackend/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
