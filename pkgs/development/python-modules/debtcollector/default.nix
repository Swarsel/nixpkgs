{
  lib,
  buildPythonPackage,
  callPackage,
  fetchPypi,
  openstackdocstheme,
  pbr,
  setuptools,
  six,
  sphinxHook,
  wrapt,
}:

buildPythonPackage rec {
  pname = "debtcollector";
  version = "3.0.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-KokX0lsOHx0NNl08HG7Px6UiselxbooaSpFRJvfM6m8=";
  };

  # check in passthru.tests.pytest to escape infinite recursion with other oslo components
  doCheck = false;

  build-system = [
    openstackdocstheme
    pbr
    setuptools
    sphinxHook
  ];

  dependencies = [
    six
    wrapt
  ];

  pyproject = true;
  pythonImportsCheck = [ "debtcollector" ];
  sphinxBuilders = [ "man" ];

  passthru.tests = {
    tests = callPackage ./tests.nix { };
  };

  meta = {
    description = "Collection of Python deprecation patterns and strategies that help you collect your technical debt in a non-destructive manner";
    homepage = "https://github.com/openstack/debtcollector";
    license = lib.licenses.asl20;
    teams = [ lib.teams.openstack ];
  };
}
