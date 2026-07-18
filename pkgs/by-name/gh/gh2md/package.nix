{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "gh2md";
  version = "2.5.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-01r/x9SrxCUN/wrEAWopHDAEEJdwKiWL9mERylaNAlA=";
  };

  # uses network
  doCheck = false;

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    six
    requests
    python-dateutil
  ];

  pyproject = true;
  pythonImportsCheck = [ "gh2md" ];

  meta = {
    description = "Export Github repository issues to markdown files";
    homepage = "https://github.com/mattduck/gh2md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ artturin ];
    mainProgram = "gh2md";
  };
})
