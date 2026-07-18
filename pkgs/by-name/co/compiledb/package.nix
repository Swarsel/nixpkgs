{
  lib,
  fetchFromGitHub,
  coreutils,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "compiledb";
  version = "0.10.7";

  src = fetchFromGitHub {
    owner = "nickdiego";
    repo = "compiledb";
    tag = finalAttrs.version;
    hash = "sha256-toqBf5q1EfZVhZN5DAtxkyFF7UlyNbqxWAIWFMwacxw=";
  };

  doCheck = true;
  nativeCheckInputs = [ python3Packages.pytestCheckHook ];

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3Packages; [
    click
    bashlex
  ];

  # fix the tests
  patchPhase = ''
    substituteInPlace tests/data/multiple_commands_oneline.txt \
        --replace-fail "/bin/echo" "${coreutils}/bin/echo"
  '';

  pyproject = true;

  meta = {
    description = "Tool for generating Clang's JSON Compilation Database files";
    homepage = "https://github.com/nickdiego/compiledb";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ sigmanificient ];
    mainProgram = "compiledb";
  };
})
