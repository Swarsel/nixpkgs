{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

let
  self = python3Packages.buildPythonApplication {
    pname = "setconf";
    version = "0.7.7";

    src = fetchFromGitHub {
      owner = "xyproto";
      repo = "setconf";
      rev = self.version;
      hash = "sha256-HYZdDtDlGrT3zssDdMW3559hhC+cPy8qkmM8d9zEa1A=";
    };

    build-system = with python3Packages; [ setuptools ];
    pyproject = true;

    meta = {
      description = "Small utility for changing settings in configuration textfiles";
      homepage = "https://github.com/xyproto/setconf";
      changelog = "https://github.com/xyproto/setconf/releases/tag/${self.src.rev}";
      license = lib.licenses.gpl2Only;
      maintainers = [ ];
      mainProgram = "setconf";
    };
  };
in
self
