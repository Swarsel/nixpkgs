{
  lib,
  fetchFromGitHub,
  python3,
  xrdb,
}:

# requires openrazer-daemon to be running on the system
# on NixOS hardware.openrazer.enable or pkgs.openrazer-daemon

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "razer-cli";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "lolei";
    repo = "razer-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uwTqDCYmG/5dyse0tF/CPG+9SlThyRyeHJ0OSBpcQio=";
  };

  buildInputs = [
    xrdb
  ];

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = [
    python3.pkgs.openrazer
  ];

  pyproject = true;

  meta = {
    description = "Command line interface for controlling Razer devices on Linux";
    homepage = "https://github.com/LoLei/razer-cli";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.kaylorben ];
    platforms = lib.platforms.linux;
    mainProgram = "razer-cli";
  };
})
