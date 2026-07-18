{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "cups-printers";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "audius";
    repo = "cups-printers";
    tag = finalAttrs.version;
    hash = "sha256-Fne7V9dEZwdV6OsQPg2gzrz/wloAOOuwlx3CqXOyWBc=";
  };

  # Project has no tests
  doCheck = false;
  build-system = with python3.pkgs; [ poetry-core ];

  dependencies = with python3.pkgs; [
    pycups
    rich
    typer
    validators
  ];

  pyproject = true;
  pythonImportsCheck = [ "cups_printers" ];

  pythonRelaxDeps = [
    "rich"
    "typer"
    "validators"
  ];

  meta = {
    description = "Tool for interacting with a CUPS server";
    homepage = "https://github.com/audius/cups-printers";
    changelog = "https://github.com/audius/cups-printers/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "cups-printers";
  };
})
