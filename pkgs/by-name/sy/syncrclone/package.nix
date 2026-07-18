{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "syncrclone";
  version = "0-unstable-2023-03-23";

  src = fetchFromGitHub {
    owner = "jwink3101";
    repo = "syncrclone";
    rev = "137c9c4cc737a383b23cd9a5a21bb079e6a8fc59";
    hash = "sha256-v81hPeu5qnMG6Sb95D88jy5x/GO781bf7efCYjbOaxs=";
  };

  build-system = with python3.pkgs; [ setuptools ];
  pyproject = true;

  pythonImportsCheck = [
    "syncrclone"
  ];

  meta = {
    description = "Bidirectional sync tool for rclone";
    homepage = "https://github.com/Jwink3101/syncrclone";
    changelog = "https://github.com/Jwink3101/syncrclone/blob/${finalAttrs.src.rev}/docs/changelog.md";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = [ ];
    mainProgram = "syncrclone";
  };
})
