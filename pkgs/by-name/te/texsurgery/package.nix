{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "texsurgery";
  version = "0.6.3";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-zoOeTRHcpDnXJ1QC7BIz9guzqL9Q7kmJ5VSGEyqanfY=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    jupyter-client
    pyparsing
  ];

  pyproject = true;

  pythonImportsCheck = [
    "texsurgery"
    "texsurgery.texsurgery"
    "texsurgery.command_line"
  ];

  meta = {
    description = "Replace some commands and environments within a TeX document by evaluating code inside a jupyter kernel";
    homepage = "https://pypi.org/project/texsurgery";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ romildo ];
    mainProgram = "texsurgery";
  };
})
