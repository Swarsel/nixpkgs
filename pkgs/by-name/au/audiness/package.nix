{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "audiness";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "audius";
    repo = "audiness";
    tag = finalAttrs.version;
    hash = "sha256-zru37eNQyY9AcbALge1qlINuxzVKq3RTNypm5Pyhkz8=";
  };

  nativeCheckInputs = with python3.pkgs; [
    pytest-mock
    pytestCheckHook
  ];

  build-system = with python3.pkgs; [ poetry-core ];

  dependencies = with python3.pkgs; [
    pytenable
    typer
    validators
  ];

  pyproject = true;
  pythonImportsCheck = [ "audiness" ];

  pythonRelaxDeps = [
    "pytenable"
    "typer"
    "validators"
  ];

  meta = {
    description = "CLI tool to interact with Nessus";
    homepage = "https://github.com/audius/audiness";
    changelog = "https://github.com/audius/audiness/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "audiness";
  };
})
