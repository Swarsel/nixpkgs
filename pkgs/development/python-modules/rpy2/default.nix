{
  lib,
  buildPythonPackage,
  fetchPypi,
  isPyPy,
  rpy2-rinterface,
  rpy2-robjects,
  setuptools,
}:

buildPythonPackage rec {
  pname = "rpy2";
  version = "3.6.7";

  src = fetchPypi {
    inherit version pname;
    hash = "sha256-8ftGSc59FOk1EzCI3sl82ifrN858xxA4X4HcpVb+jJ8=";
  };

  build-system = [ setuptools ];

  dependencies = [
    rpy2-rinterface
    rpy2-robjects
  ];

  disabled = isPyPy;
  pyproject = true;

  pythonImportsCheck = [
    "rpy2"
  ];

  meta = {
    description = "Python interface to R";
    homepage = "https://rpy2.github.io/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ joelmo ];
    platforms = lib.platforms.unix;
  };
}
