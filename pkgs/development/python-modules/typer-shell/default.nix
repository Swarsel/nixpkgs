{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  click-shell,
  hatchling,
  iterfzf,
  pyyaml,
  rich,
  typer,
}:

buildPythonPackage rec {
  pname = "typer-shell";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "FergusFettes";
    repo = "typer-shell";
    tag = "v${version}";
    hash = "sha256-vjinzBCaEPWbroxT7OmUQIvtwlPivYO0soGqvyRXVc4=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ hatchling ];

  dependencies = [
    click
    click-shell
    iterfzf
    pyyaml
    rich
    typer
  ];

  pyproject = true;
  pythonImportsCheck = [ "typer_shell" ];

  pythonRelaxDeps = [
    "iterfzf"
    "rich"
    "typer"
  ];

  meta = {
    description = "Library for making beautiful shells/REPLs with Typer";
    homepage = "https://github.com/FergusFettes/typer-shell";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
}
