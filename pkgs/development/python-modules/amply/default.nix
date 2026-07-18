{
  lib,
  buildPythonPackage,
  docutils,
  fetchPypi,
  pyparsing,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "amply";
  version = "0.1.7";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Z1tzt9dhE922z3Q8wW7ZJbzMTnLvZpkfDHNyBkYys8k=";
  };

  nativeBuildInputs = [ setuptools-scm ];

  propagatedBuildInputs = [
    docutils
    pyparsing
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "amply" ];

  meta = {
    description = ''
      Allows you to load and manipulate AMPL/GLPK data as Python data structures
    '';

    homepage = "https://github.com/willu47/amply";
    license = lib.licenses.epl10;
    maintainers = with lib.maintainers; [ ris ];
  };
}
