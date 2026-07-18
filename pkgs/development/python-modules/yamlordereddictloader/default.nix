{
  lib,
  buildPythonPackage,
  fetchPypi,
  pyyaml,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "yamlordereddictloader";
  version = "0.4.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-Nq8vYhD8/12k/EwS4dgV+XPc60EETnleHwYRXWNLyhM=";
  };

  # no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ pyyaml ];
  pyproject = true;
  pythonImportsCheck = [ "yamlordereddictloader" ];

  meta = {
    description = "YAML loader and dump for PyYAML allowing to keep keys order";
    homepage = "https://github.com/fmenabe/python-yamlordereddictloader";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
