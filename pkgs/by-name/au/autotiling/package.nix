{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "autotiling";
  version = "1.9.3";

  src = fetchFromGitHub {
    owner = "nwg-piotr";
    repo = "autotiling";
    tag = "v${finalAttrs.version}";
    hash = "sha256-k+UiAGMB/fJiE+C737yGdyTpER1ciZrMkZezkcn/4yk=";
  };

  doCheck = false;

  build-system = [
    python3Packages.setuptools
  ];

  dependencies = [
    python3Packages.i3ipc
    python3Packages.importlib-metadata
  ];

  pyproject = true;

  meta = {
    description = "Script for sway and i3 to automatically switch the horizontal / vertical window split orientation";
    homepage = "https://github.com/nwg-piotr/autotiling";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ artturin ];
    platforms = lib.platforms.linux;
    mainProgram = "autotiling";
  };
})
