{
  lib,
  fetchFromGitHub,
  python3Packages,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "cursewords";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "thisisparker";
    repo = "cursewords";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Ssr15kSdWmyMFFG5uCregrpGQ3rI2cMXqY9+/a3gs84=";
  };

  doCheck = false; # no tests

  build-system = [
    python3Packages.setuptools
  ];

  dependencies = [
    python3Packages.blessed
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "blessed"
  ];

  meta = {
    description = "Graphical command line program for solving crossword puzzles in the terminal";
    homepage = "https://github.com/thisisparker/cursewords";
    license = lib.licenses.agpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "cursewords";
  };
})
