{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "python-path";
  version = "0.1.3";

  # no tags on GitHub
  src = fetchPypi {
    inherit version;
    hash = "sha256-ti2arB2k2u4/A27QiFMs+LaGZtOqEDVn3CK2U5MWyLM=";
    pname = "python_path";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "python_path" ];

  meta = {
    description = "Clean way to import scripts on other folders via a context manager";
    homepage = "https://github.com/cgarciae/python_path";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
