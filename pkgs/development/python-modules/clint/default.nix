{
  lib,
  args,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "clint";
  version = "0.5.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-BSJMMrEHVWPQsW0AFfqvnaQ6ohTkohQOUfCHieekxao=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ args ];
  pyproject = true;
  pythonImportsCheck = [ "clint" ];

  meta = {
    description = "Python Command Line Interface Tools";
    homepage = "https://github.com/kennethreitz/clint";
    license = lib.licenses.isc;
    maintainers = [ ];
  };
}
