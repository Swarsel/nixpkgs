{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "bitwarden-menu";
  version = "0.4.5";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-vUlNqSVdGhfN5WjDjf1ub32Y2WoBndIdFzfCNwo5+Vg=";
    pname = "bitwarden_menu";
  };

  nativeBuildInputs = with python3Packages; [
    hatch-vcs
    hatchling
  ];

  propagatedBuildInputs = with python3Packages; [
    pynput
    xdg-base-dirs
  ];

  doCheck = false;
  pyproject = true;

  meta = {
    description = "Dmenu/Rofi frontend for managing Bitwarden vaults. Uses the Bitwarden CLI tool to interact with the Bitwarden database";
    homepage = "https://github.com/firecat53/bitwarden-menu";
    changelog = "https://github.com/firecat53/bitwarden-menu/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aman9das ];
    mainProgram = "bwm";
  };
})
