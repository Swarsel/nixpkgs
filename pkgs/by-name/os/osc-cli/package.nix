{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "osc-cli";
  version = "1.11.0";

  src = fetchFromGitHub {
    owner = "outscale";
    repo = "osc-cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-7WXy+1NHwFvYmyi5xGfWpq/mbVGJ3WkgP5WQd5pvcC0=";
  };

  # Skipping tests as they require working access and secret keys
  doCheck = false;

  build-system = [
    python3.pkgs.setuptools
  ];

  dependencies = with python3.pkgs; [
    defusedxml
    fire
    requests
    typing-extensions
    xmltodict
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "defusedxml"
  ];

  meta = {
    description = "Official Outscale CLI providing connectors to Outscale API";
    homepage = "https://github.com/outscale/osc-cli";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ nicolas-goudry ];
    mainProgram = "osc-cli";
  };
})
