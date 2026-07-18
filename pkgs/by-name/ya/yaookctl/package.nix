{
  lib,
  fetchFromGitLab,
  nix-update-script,
  python3,
}:
python3.pkgs.buildPythonApplication {
  pname = "yaookctl";
  version = "0-unstable-2026-07-02";

  src = fetchFromGitLab {
    owner = "yaook";
    repo = "yaookctl";
    rev = "d444a887e0350a62b8b23d761a849ec7db46ad65";
    hash = "sha256-EWKKwPnR15qkRuhuGRyj5otwUVX+sOmRei4WfN3aRpQ=";
  };

  build-system = [ python3.pkgs.setuptools ];

  dependencies = with python3.pkgs; [
    babel
    click
    click-option-group
    kubernetes-asyncio
    prettytable
    typing-extensions
  ];

  dontCheckRuntimeDeps = true;
  pyproject = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    description = "Toolbox for interacting with Yaook clusters";
    homepage = "https://gitlab.com/yaook/yaookctl";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lykos153 ];
    mainProgram = "yaookctl";
  };
}
