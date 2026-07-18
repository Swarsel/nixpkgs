{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "typr";
  version = "1.0.1.21";

  src = fetchFromGitHub {
    owner = "DriftingOtter";
    repo = "Typr";
    tag = finalAttrs.version;
    hash = "sha256-49e5tnX/vea3xLJP62Sj2gCdjbfsulIU48X/AR/3IBI=";
  };

  doCheck = false; # absent
  build-system = with python3Packages; [ setuptools ];
  dependencies = with python3Packages; [ rich ];
  pyproject = true;

  meta = {
    description = "Your Personal Typing Tutor";
    homepage = "https://github.com/DriftingOtter/Typr";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ artur-sannikov ];
    mainProgram = "typr";
  };
})
