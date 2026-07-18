{
  lib,
  buildPythonPackage,
  callPackage,
  fetchPypi,
  netaddr,
  oslo-i18n,
  pbr,
  pyyaml,
  requests,
  rfc3986,
  setuptools,
  stevedore,
}:

buildPythonPackage rec {
  pname = "oslo-config";
  version = "10.5.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-juozVsk4KMLWG+oesZuM14YKPtr/StJnjXdN01NzDfo=";
    pname = "oslo_config";
  };

  postPatch = ''
    # only a small portion of the listed packages are actually needed for running the tests
    # so instead of removing them one by one remove everything
    rm test-requirements.txt
  '';

  # check in passthru.tests.pytest to escape infinite recursion with other oslo components
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    netaddr
    oslo-i18n
    pbr
    pyyaml
    requests
    rfc3986
    stevedore
  ];

  pyproject = true;
  pythonImportsCheck = [ "oslo_config" ];

  passthru.tests = {
    tests = callPackage ./tests.nix { };
  };

  meta = {
    description = "Oslo Configuration API";
    homepage = "https://github.com/openstack/oslo.config";
    license = lib.licenses.asl20;
    teams = [ lib.teams.openstack ];
  };
}
