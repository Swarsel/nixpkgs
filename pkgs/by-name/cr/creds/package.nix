{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "creds";
  version = "0.5.3";

  src = fetchFromGitHub {
    owner = "ihebski";
    repo = "DefaultCreds-cheat-sheet";
    tag = "creds-v${finalAttrs.version}";
    hash = "sha256-nATmzEUwvJwzPZs+bO+/6ZHIrGgvjApaEwVpMyCXmik=";
  };

  postPatch = ''
    substituteInPlace creds \
      --replace-fail "pathlib.Path(__file__).parent" "pathlib.Path.home()"
  '';

  # Project has no tests
  doCheck = false;

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    fire
    prettytable
    requests
    tinydb
  ];

  pyproject = true;
  pythonRelaxDeps = [ "tinydb" ];
  pythonRemoveDeps = [ "pathlib" ];

  meta = {
    description = "Tool to search a collection of default credentials";
    homepage = "https://github.com/ihebski/DefaultCreds-cheat-sheet";
    changelog = "https://github.com/ihebski/DefaultCreds-cheat-sheet/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "creds";
  };
})
