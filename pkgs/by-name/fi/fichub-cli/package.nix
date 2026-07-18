{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "fichub-cli";
  version = "0.10.3";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-MTExXpuCwi/IfNDUVLMcxfFRwHHNfGJerHkHnh6/hls=";
    pname = "fichub_cli";
  };

  # Loading tests tries to download something from pypi.org
  doCheck = false;

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
  ];

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    platformdirs
    beautifulsoup4
    click
    click-plugins
    colorama
    loguru
    requests
    tqdm
    typer
  ];

  pyproject = true;

  pythonImportsCheck = [
    "fichub_cli"
  ];

  meta = {
    description = "CLI for the fichub.net API";
    homepage = "https://github.com/FicHub/fichub-cli";
    changelog = "https://github.com/FicHub/fichub-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.samasaur ];
    mainProgram = "fichub_cli";
  };
})
