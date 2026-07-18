{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "latex2pydata";
  version = "0.5.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-vMrSCDw6btcEkmU9XYGczZNgo6/Dwxnb7PSW+6BXQok=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  pyproject = true;

  meta = {
    description = "Send data from LaTeX to Python using Python literal format";
    homepage = "https://github.com/gpoore/latex2pydata";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ romildo ];
    platforms = lib.platforms.unix;
  };
}
