{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cliff,
  debtcollector,
  # Tests
  fixtures,
  hacking,
  keystoneauth1,
  netaddr,
  openstacksdk,
  osc-lib,
  oslo-i18n,
  oslo-log,
  oslo-serialization,
  oslo-utils,
  oslotest,
  osprofiler,
  # Build and Runtime
  pbr,
  python-keystoneclient,
  python-openstackclient,
  requests,
  requests-mock,
  setuptools,
  stestr,
  tempest,
  testscenarios,
  testtools,
}:

buildPythonPackage rec {
  pname = "python-neutronclient";
  version = "11.8.0";

  src = fetchFromGitHub {
    owner = "openstack";
    repo = "python-neutronclient";
    tag = version;
    hash = "sha256-wf+ZTLaBEzQPRVQOZ6JaqH88ymgGIgtRKKdJi2UvKdM=";
  };

  env.PBR_VERSION = version;

  nativeCheckInputs = [
    hacking
    fixtures
    oslotest
    osprofiler
    python-openstackclient
    requests-mock
    stestr
    testtools
    testscenarios
    tempest
  ];

  checkPhase = ''
    runHook preCheck

    stestr run

    runHook postCheck
  '';

  build-system = [
    setuptools
    pbr
  ];

  dependencies = [
    cliff
    debtcollector
    netaddr
    openstacksdk
    osc-lib
    oslo-i18n
    oslo-log
    oslo-serialization
    oslo-utils
    keystoneauth1
    python-keystoneclient
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "neutronclient" ];

  meta = {
    description = "Python bindings for the OpenStack Networking API";
    homepage = "https://github.com/openstack/python-neutronclient/";
    license = lib.licenses.asl20;
    teams = [ lib.teams.openstack ];
  };
}
