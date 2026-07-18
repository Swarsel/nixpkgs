{
  lib,
  fetchPypi,
  gitMinimal,
  python3Packages,
  writableTmpDirAsHomeHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "git-up";
  version = "2.3.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-SncbnK6LxsleKRa/sSCm/8dsgPw/XJGvYfkcIeWYDy4=";
    pname = "git_up";
  };

  # required in PATH for tool to work
  propagatedBuildInputs = [ gitMinimal ];

  nativeCheckInputs = [
    gitMinimal
    python3Packages.pytest7CheckHook
    writableTmpDirAsHomeHook
  ];

  # git fails without email address
  preCheck = ''
    git config --global user.email "nobody@example.com"
    git config --global user.name "Nobody"
  '';

  postInstall = ''
    rm -r $out/${python3Packages.python.sitePackages}/PyGitUp/tests
  '';

  build-system = with python3Packages; [
    poetry-core
  ];

  dependencies = with python3Packages; [
    colorama
    gitpython
    termcolor
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "termcolor"
  ];

  meta = {
    description = "Git pull replacement that rebases all local branches when pulling";
    homepage = "https://github.com/msiemens/PyGitUp";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ peterhoeg ];
    platforms = lib.platforms.all;
    mainProgram = "git-up";
  };
})
