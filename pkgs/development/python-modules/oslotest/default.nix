{
  lib,
  buildPythonPackage,
  callPackage,
  fetchPypi,
  fixtures,
  pbr,
  python-subunit,
  six,
}:

buildPythonPackage rec {
  pname = "oslotest";
  version = "6.1.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-XOlzR3NPCMpia7SWliqLx6266Wk3MPWFnZxSk9Si/YA=";
  };

  nativeBuildInputs = [ pbr ];

  propagatedBuildInputs = [
    fixtures
    six
    python-subunit
  ];

  # check in passthru.tests.pytest to escape infinite recursion with other oslo components
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "oslotest" ];

  passthru.tests = {
    tests = callPackage ./tests.nix { };
  };

  meta = {
    description = "Oslo test framework";
    homepage = "https://github.com/openstack/oslotest";
    license = lib.licenses.asl20;
    teams = [ lib.teams.openstack ];
  };
}
