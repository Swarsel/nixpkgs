{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  loguru,
  platformdirs,
  pydantic,
  pytestCheckHook,
  setuptools,
  typer,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "maison";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "dbatten5";
    repo = "maison";
    tag = "v${version}";
    hash = "sha256-F0mxOeLFDCiPhhKaaUy4qV//Pb2JXCtOLNB1uW2KWZY=";
  };

  checkInputs = [
    pydantic
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    loguru
    platformdirs
    typer
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "maison" ];

  meta = {
    description = "Library to read settings from config files";
    homepage = "https://github.com/dbatten5/maison";
    changelog = "https://github.com/dbatten5/maison/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "maison";
  };
}
