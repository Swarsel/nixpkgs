{
  lib,
  fetchPypi,
  python3Packages,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "gay";
  version = "1.3.4";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-pSxRrXnv4tfu7awVnOsQwC2ZOS4qsfCphFR/fpTNdPc=";
  };

  build-system = [ python3Packages.setuptools ];
  pyproject = true;

  meta = {
    description = "Colour your text / terminal to be more gay";
    homepage = "https://github.com/ms-jpq/gay";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ CodeLongAndProsper90 ];
    mainProgram = "gay";
  };
})
