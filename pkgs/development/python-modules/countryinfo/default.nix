{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pydantic,
  pytestCheckHook,
  typer,
}:

buildPythonPackage (finalAttrs: {
  pname = "countryinfo";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "porimol";
    repo = "countryinfo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PE9XiVH6XE+OSySL5Lo0MPWyIEX8xgeHQB7MttMfmz8=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];

  dependencies = [
    pydantic
    typer
  ];

  pyproject = true;
  pythonImportsCheck = [ "countryinfo" ];
  pythonRelaxDeps = [ "typer" ];

  meta = {
    description = "Data about countries, ISO info and states/provinces within them";
    homepage = "https://github.com/porimol/countryinfo";
    changelog = "https://github.com/porimol/countryinfo/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ cizniarova ];
  };
})
