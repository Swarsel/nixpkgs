{
  lib,
  fetchPypi,
  python3,
}:

with python3.pkgs;

buildPythonPackage rec {
  pname = "shell-genie";
  version = "0.2.10";

  src = fetchPypi {
    inherit version;
    hash = "sha256-z7LiAq2jLzqjg4Q/r9o7M6VbedeT34NyPpgctfqBp+8=";
    pname = "shell_genie";
  };

  # No tests available
  doCheck = false;

  build-system = [
    poetry-core
  ];

  dependencies = [
    colorama
    openai
    pyperclip
    rich
    shellingham
    typer
  ];

  pyproject = true;

  pythonImportsCheck = [
    "shell_genie"
  ];

  pythonRelaxDeps = [
    "openai"
    "typer"
  ];

  meta = {
    description = "Describe your shell commands in natural language";
    homepage = "https://github.com/dylanjcastillo/shell-genie";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ onny ];
    mainProgram = "shell-genie";
  };
}
