{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  decorator,
  fixtures,
  keystoneauth1,
  openstackdocstheme,
  openstacksdk,
  osc-lib,
  oslo-i18n,
  oslo-log,
  oslo-serialization,
  oslo-utils,
  oslotest,
  osprofiler,
  pbr,
  prettytable,
  python-openstackclient,
  requests,
  requests-mock,
  setuptools,
  sphinxHook,
  stestr,
  stevedore,
  testtools,
}:

buildPythonPackage rec {
  pname = "python-magnumclient";
  version = "4.10.0";

  src = fetchFromGitHub {
    owner = "openstack";
    repo = "python-magnumclient";
    tag = version;
    hash = "sha256-kOnx2Fsx6WK7Z3z7O6so1LOjjyPiEB0jDFzOl7WlMS0=";
  };

  nativeBuildInputs = [
    openstackdocstheme
    sphinxHook
  ];

  env.PBR_VERSION = version;

  nativeCheckInputs = [
    fixtures
    python-openstackclient
    osprofiler
    oslotest
    requests-mock
    stestr
    testtools
  ];

  checkPhase = ''
    runHook preCheck
    stestr run
    runHook postCheck
  '';

  build-system = [
    pbr
    setuptools
  ];

  dependencies = [
    cryptography
    decorator
    keystoneauth1
    openstacksdk
    osc-lib
    oslo-i18n
    oslo-log
    oslo-serialization
    oslo-utils
    prettytable
    requests
    stevedore
  ];

  pyproject = true;
  pythonImportsCheck = [ "magnumclient" ];
  sphinxBuilders = [ "man" ];

  meta = {
    description = "Client library for OpenStack Magnum API";
    homepage = "https://github.com/openstack/python-magnumclient";
    license = lib.licenses.asl20;
    mainProgram = "magnum";
    teams = [ lib.teams.openstack ];
  };
}
