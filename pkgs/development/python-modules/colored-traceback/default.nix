{
  lib,
  buildPythonPackage,
  fetchPypi,
  pygments,
  setuptools,
}:

buildPythonPackage rec {
  pname = "colored-traceback";
  version = "0.4.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-7LyOQfBxLqgZMdfNQ2uL658+/xWV0kmPGD4O9ptW/oQ=";
  };

  # No setuptools tests for the package.
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ pygments ];
  pyproject = true;
  pythonImportsCheck = [ "colored_traceback" ];

  meta = {
    description = "Automatically color Python's uncaught exception tracebacks";
    homepage = "https://github.com/staticshock/colored-traceback.py";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ pamplemousse ];
  };
}
