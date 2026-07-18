{
  lib,
  fetchFromGitHub,
  nix-update-script,
  python3Packages,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "nodezator";
  version = "1.5.5";

  src = fetchFromGitHub {
    owner = "IndieSmiths";
    repo = "nodezator";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9lEizhTwihv909xDgmcel9eCL7VfVDrWDtWghdjSH90=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    pygame-ce
    numpy
  ];

  pyproject = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Generalist Python node editor";
    homepage = "https://nodezator.com";
    changelog = "https://github.com/IndieSmiths/nodezator/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ theobori ];
    mainProgram = "nodezator";
    downloadPage = "https://github.com/IndieSmiths/nodezator";
  };
})
