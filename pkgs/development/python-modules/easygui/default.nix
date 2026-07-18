{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  tkinter,
}:

buildPythonPackage (finalAttrs: {
  pname = "easygui";
  version = "0.98.3";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-1lP/ee4fQvY7WgkPL5jOAjNdhq2JY7POJmGAXK/pmgQ=";
  };

  doCheck = false; # No tests available
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ tkinter ];
  pyproject = true;
  pythonImportsCheck = [ "easygui" ];

  meta = {
    description = "Very simple, very easy GUI programming in Python";
    homepage = "https://github.com/robertlugg/easygui";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
})
