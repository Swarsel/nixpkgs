{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  pytestCheckHook,
  typer,
}:

buildPythonPackage rec {
  pname = "typer-injector";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "BenjyWiener";
    repo = "typer-injector";
    tag = "v${version}";
    hash = "sha256-rhYeTNQh1DZuQ7/yNleZPMMBiF29OrcT0vr/yb5HJXk=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    typer
  ];

  pyproject = true;
  pythonImportsCheck = [ "typer_injector" ];

  meta = {
    description = "Dependency injection for Typer";
    homepage = "https://github.com/BenjyWiener/typer-injector";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
