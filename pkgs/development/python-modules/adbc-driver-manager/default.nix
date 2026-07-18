{
  lib,
  buildPythonPackage,
  # build-system
  cython,
  fetchPypi,
  setuptools,
  # dependencies
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "adbc-driver-manager";
  version = "1.11.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-xkqqvrWBAQmrPSlhAI8bAU6fLYez30QWwqCApAI3r1A=";
    pname = "adbc_driver_manager";
  };

  # Tests create a circular dependency on adbc-driver-sqlite
  doCheck = false;
  __structuredAttrs = true;

  build-system = [
    cython
    setuptools
  ];

  dependencies = [
    typing-extensions
  ];

  pyproject = true;

  pythonImportsCheck = [
    "adbc_driver_manager"
  ];

  meta = {
    description = "A generic entrypoint for ADBC drivers";
    homepage = "https://pypi.org/project/adbc-driver-manager";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
})
