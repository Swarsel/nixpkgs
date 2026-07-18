{
  lib,
  buildPythonPackage,
  callPackage,
  fetchPypi,
  # optional-dependencies
  rich,
  # build-system
  setuptools,
  # dependencies
  vcs-versioning,
}:

buildPythonPackage rec {
  pname = "setuptools-scm";
  version = "10.0.5";

  src = fetchPypi {
    inherit version;
    hash = "sha256-u7qP51RRbN79AX9EVnIXdebvlmK9eIf7Uq4mgT1IOMM=";
    pname = "setuptools_scm";
  };

  postPatch = null;
  # check in passthru.tests.pytest to escape infinite recursion on pytest
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    setuptools
    vcs-versioning
  ];

  optional-dependencies = {
    rich = [ rich ];
  };

  pyproject = true;
  pythonImportsCheck = [ "setuptools_scm" ];
  setupHook = ./setup-hook.sh;

  passthru.tests = {
    pytest = callPackage ./tests.nix { };
  };

  meta = {
    description = "Handles managing your python package versions in scm metadata";
    homepage = "https://github.com/pypa/setuptools_scm/";
    changelog = "https://github.com/pypa/setuptools_scm/blob/${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nickcao ];
  };
}
