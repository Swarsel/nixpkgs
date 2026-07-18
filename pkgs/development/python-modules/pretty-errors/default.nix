{
  lib,
  buildPythonPackage,
  colorama,
  fetchPypi,
  setuptools,
  wheel,
}:

buildPythonPackage rec {
  pname = "pretty-errors";
  version = "1.2.25";

  src = fetchPypi {
    inherit version;
    hash = "sha256-oWulx1LIfCY7+S+LS1hiTjseKScak5H1ZPErhuk8Z1U=";
    pname = "pretty_errors";
  };

  # No test
  doCheck = false;

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [ colorama ];
  pyproject = true;
  pythonImportsCheck = [ "pretty_errors" ];

  meta = {
    description = "Prettifies Python exception output to make it legible";
    homepage = "https://pypi.org/project/pretty-errors/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
