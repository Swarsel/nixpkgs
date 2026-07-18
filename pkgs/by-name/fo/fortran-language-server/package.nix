{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "fortran-language-server";
  version = "1.12.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-7Dkh7yPX4rULkzfJFxg47YxrCaxuHk+k3TOINHS9T5A=";
  };

  checkPhase = "$out/bin/fortls --help 1>/dev/null";

  build-system = [
    python3Packages.setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "fortls" ];

  meta = {
    description = "FORTRAN Language Server for the Language Server Protocol";
    homepage = "https://pypi.org/project/fortran-language-server/";
    license = [ lib.licenses.mit ];
    maintainers = [ lib.maintainers.sheepforce ];
    mainProgram = "fortls";
  };
})
