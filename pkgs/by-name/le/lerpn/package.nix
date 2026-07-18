{
  lib,
  fetchFromGitea,
  python3,
}:

python3.pkgs.buildPythonApplication {
  pname = "lerpn";
  version = "unstable-2023-06-09";

  src = fetchFromGitea {
    owner = "alexisvl";
    repo = "lerpn";
    rev = "b65e56cfbbb38f8200e7b0c18b3a585ae768c6e2";
    hash = "sha256-4xqBHcOWHAvQtXS9CJWTGTdE4SGHxjghZY+/KPUgX70=";
    domain = "gitea.alexisvl.rocks";
  };

  checkPhase = ''
    runHook preCheck
    patchShebangs test

    substituteInPlace test --replace-fail "#raise TestFailedException()" "sys.exit(1)"
    ./test
    runHook postCheck
  '';

  build-system = with python3.pkgs; [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "LerpnApp" ];

  meta = {
    description = "Curses RPN calculator written in straight Python";
    homepage = "https://gitea.alexisvl.rocks/alexisvl/lerpn";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    mainProgram = "lerpn";
  };
}
