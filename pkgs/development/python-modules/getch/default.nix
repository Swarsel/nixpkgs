{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "getch";
  version = "1.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-psInF8EAUc5luPt73bFxr3BbEXXmlKc76VaZD2CJ2LE=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "getch" ];

  meta = {
    description = "Does single char input, like C getch/getche";
    homepage = "https://pypi.org/project/getch/";
    license = lib.licenses.publicDomain;
    maintainers = with lib.maintainers; [ fab ];
  };
})
