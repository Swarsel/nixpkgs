{
  lib,
  buildPythonPackage,
  callPackage,
  cliff,
  fetchPypi,
  fixtures,
  flit-core,
  python-subunit,
  testtools,
  tomlkit,
  voluptuous,
}:

buildPythonPackage rec {
  pname = "stestr";
  version = "4.2.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Rexjny0cw3LjYwYTuT83zynT3+adSdTz+UCNN7Ebwpw=";
  };

  # check in passthru.tests.pytest to escape infinite recursion with other oslo components
  doCheck = false;

  build-system = [
    flit-core
  ];

  dependencies = [
    cliff
    fixtures
    python-subunit
    testtools
    tomlkit
    voluptuous
  ];

  pyproject = true;
  pythonImportsCheck = [ "stestr" ];

  passthru.tests = {
    tests = callPackage ./tests.nix { };
  };

  meta = {
    description = "Parallel Python test runner built around subunit";
    homepage = "https://github.com/mtreinish/stestr";
    license = lib.licenses.asl20;
    mainProgram = "stestr";
    teams = [ lib.teams.openstack ];
  };
}
