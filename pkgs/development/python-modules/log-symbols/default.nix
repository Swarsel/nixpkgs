{
  lib,
  buildPythonPackage,
  colorama,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "log-symbols";
  version = "0.0.14";

  src = fetchPypi {
    inherit version;
    hash = "sha256-zwu8b+Go5T8NF0pxa8YlxPhwQ8wh61XdinQM/iJoBVY=";
    pname = "log_symbols";
  };

  # Tests are not included in the PyPI distribution and the git repo does not have tagged releases
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ colorama ];
  pyproject = true;
  pythonImportsCheck = [ "log_symbols" ];

  meta = {
    description = "Colored Symbols for Various Log Levels";
    homepage = "https://github.com/manrajgrover/py-log-symbols";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ urbas ];
  };
}
