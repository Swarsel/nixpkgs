{
  lib,
  buildPythonPackage,
  callPackage,
  distutils,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pbr";
  version = "7.0.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-tGAE7DClMkZyaD7ISK7Z6PxQCw0mHUCjIpwtK7/O3Ck=";
  };

  # check in passthru.tests.pytest to escape infinite recursion with fixtures
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    distutils # for distutils.command in pbr/packaging.py
    setuptools # for pkg_resources
  ];

  pyproject = true;
  pythonImportsCheck = [ "pbr" ];

  passthru.tests = {
    tests = callPackage ./tests.nix { };
  };

  meta = {
    description = "Python Build Reasonableness";
    homepage = "https://github.com/openstack/pbr";
    license = lib.licenses.asl20;
    mainProgram = "pbr";
    teams = [ lib.teams.openstack ];
  };
}
