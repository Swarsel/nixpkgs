{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "soco-cli";
  version = "0.4.85";

  src = fetchFromGitHub {
    owner = "avantrec";
    repo = "soco-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-g/tUK6S9uk4PxE3xscJag8fPYA2PdsCccfP+7Wi1ji0=";
  };

  # Tests wants to communicate with hardware
  doCheck = false;
  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    fastapi
    rangehttpserver
    soco
    tabulate
    uvicorn
  ];

  pyproject = true;
  pythonImportsCheck = [ "soco_cli" ];

  meta = {
    description = "Command-line interface to control Sonos sound systems";
    homepage = "https://github.com/avantrec/soco-cli";
    changelog = "https://github.com/avantrec/soco-cli/blob/${finalAttrs.src.tag}/CHANGELOG.txt";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "sonos";
  };
})
