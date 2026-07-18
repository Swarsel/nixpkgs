{
  lib,
  fetchPypi,
  nix-update-script,
  python3,
  versionCheckHook,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "snakefmt";
  version = "1.1.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-cvdAXFVEegcuWoNWv/D3Etije73dt50O2EPOlFOnXQg=";
  };

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  build-system = with python3.pkgs; [ hatchling ];

  dependencies = with python3.pkgs; [
    black
    click
  ];

  pyproject = true;
  pythonImportsCheck = [ "snakefmt" ];

  pythonRelaxDeps = [
    "black"
    "click"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Uncompromising Snakemake code formatter";
    homepage = "https://pypi.org/project/snakefmt/";
    changelog = "https://github.com/snakemake/snakefmt/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jolars ];
    mainProgram = "snakefmt";
  };
})
