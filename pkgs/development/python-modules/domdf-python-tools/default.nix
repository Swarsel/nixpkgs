{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatch-requirements-txt,
  natsort,
  typing-extensions,
}:
buildPythonPackage rec {
  pname = "domdf-python-tools";
  version = "3.10.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-KuMI0vTx6RRfX0ulf4QPv9HCmD7ibkgkNHeJZJ064pg=";
    pname = "domdf_python_tools";
  };

  build-system = [ hatch-requirements-txt ];

  dependencies = [
    natsort
    typing-extensions
  ];

  pyproject = true;

  meta = {
    description = "Helpful functions for Python";
    homepage = "https://github.com/domdfcoding/domdf_python_tools";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tyberius-prime ];
  };
}
