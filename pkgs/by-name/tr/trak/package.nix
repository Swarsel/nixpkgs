{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "trak";
  version = "0.0.5";

  src = fetchFromGitHub {
    owner = "lcfd";
    repo = "trak";
    rev = "v${finalAttrs.version}";
    hash = "sha256-YJMX7pNRWdNPyWNZ1HfpdYsKSStRWLcianLz6nScMa8=";
  };

  build-system = [ python3Packages.poetry-core ];

  dependencies = with python3Packages; [
    questionary
    typer
  ];

  pyproject = true;
  sourceRoot = "${finalAttrs.src.name}/cli";

  meta = {
    description = "Keep a record of the time you dedicate to your projects";
    homepage = "https://github.com/lcfd/trak";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ buurro ];
    mainProgram = "trak";
  };
})
