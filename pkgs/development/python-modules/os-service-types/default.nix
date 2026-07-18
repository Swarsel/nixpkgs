{
  lib,
  buildPythonPackage,
  callPackage,
  fetchPypi,
  pbr,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "os-service-types";
  version = "1.8.2";

  src = fetchPypi {
    inherit version;
    hash = "sha256-q3ZI1yMoSZQxluG7AKMOLiXmAPo7V7skHRW39SG1tXU=";
    pname = "os_service_types";
  };

  postPatch = ''
    # only a small portion of the listed packages are actually needed for running the tests
    # so instead of removing them one by one remove everything
    rm test-requirements.txt
  '';

  # check in passthru.tests.pytest to escape infinite recursion with other oslo components
  doCheck = false;

  build-system = [
    pbr
    setuptools
  ];

  dependencies = [
    pbr
    six
  ];

  pyproject = true;
  pythonImportsCheck = [ "os_service_types" ];

  passthru.tests = {
    tests = callPackage ./tests.nix { };
  };

  meta = {
    description = "Python library for consuming OpenStack service-types-authority data";
    homepage = "https://github.com/openstack/os-service-types";
    license = lib.licenses.asl20;
    teams = [ lib.teams.openstack ];
  };
}
