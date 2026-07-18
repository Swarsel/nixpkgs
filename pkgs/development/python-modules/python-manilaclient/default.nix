{
  lib,
  buildPythonPackage,
  callPackage,
  debtcollector,
  fetchPypi,
  keystoneauth1,
  openstackdocstheme,
  osc-lib,
  oslo-config,
  oslo-log,
  oslo-serialization,
  oslo-utils,
  pbr,
  prettytable,
  requests,
  setuptools,
  sphinxHook,
  sphinxcontrib-programoutput,
}:

buildPythonPackage rec {
  pname = "python-manilaclient";
  version = "6.0.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-EQwsbwZzFXE+KKDH2SxlC6G8oFvdXo2bK4bJKJZfrVw=";
    pname = "python_manilaclient";
  };

  # Checks moved to 'passthru.tests' to workaround infinite recursion
  doCheck = false;

  build-system = [
    openstackdocstheme
    setuptools
    sphinxHook
    sphinxcontrib-programoutput
  ];

  dependencies = [
    debtcollector
    keystoneauth1
    osc-lib
    oslo-config
    oslo-log
    oslo-serialization
    oslo-utils
    pbr
    prettytable
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "manilaclient" ];
  sphinxBuilders = [ "man" ];

  passthru.tests = {
    tests = callPackage ./tests.nix { };
  };

  meta = {
    description = "Client library for OpenStack Manila API";
    homepage = "https://github.com/openstack/python-manilaclient";
    license = lib.licenses.asl20;
    mainProgram = "manila";
    teams = [ lib.teams.openstack ];
  };
}
