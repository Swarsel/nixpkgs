{
  lib,
  autopage,
  buildPythonPackage,
  callPackage,
  cmd2,
  fetchPypi,
  fetchpatch,
  openstackdocstheme,
  pbr,
  prettytable,
  pyyaml,
  sphinxHook,
  stevedore,
}:

buildPythonPackage rec {
  pname = "cliff";
  version = "4.13.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-6Um1hbm2RUnehziM79Seh91jCVziufO5j5Ej182Uvho=";
  };

  patches = [
    # Fix compatibility with Python 3.14.3
    (fetchpatch {
      hash = "sha256-jcjZKJlcJ8C4VKJejb/bjJ6Li4JjeC2xWK/nFWzIL2c=";
      url = "https://github.com/openstack/cliff/commit/391261c849c994ca2d3f42926497e633047ed8c7.patch";
    })
  ];

  # check in passthru.tests.pytest to escape infinite recursion with stestr
  doCheck = false;

  build-system = [
    openstackdocstheme
    pbr
    sphinxHook
  ];

  dependencies = [
    autopage
    cmd2
    prettytable
    pyyaml
    stevedore
  ];

  pyproject = true;
  pythonImportsCheck = [ "cliff" ];
  sphinxBuilders = [ "man" ];

  passthru.tests = {
    pytest = callPackage ./tests.nix { };
  };

  meta = {
    description = "Command Line Interface Formulation Framework";
    homepage = "https://github.com/openstack/cliff";
    license = lib.licenses.asl20;
    teams = [ lib.teams.openstack ];
  };
}
