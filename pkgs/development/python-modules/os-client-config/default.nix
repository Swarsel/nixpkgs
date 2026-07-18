{
  lib,
  buildPythonPackage,
  fetchPypi,
  fixtures,
  jsonschema,
  openstacksdk,
  oslotest,
  pbr,
  python-glanceclient,
  python-subunit,
  setuptools,
  stestr,
  testscenarios,
  testtools,
}:

buildPythonPackage rec {
  pname = "os-client-config";
  version = "2.3.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-4WomDy/VAK8U8Ve5t7fWkpLOg7D4pGHsaM5qikKWfL0=";
    pname = "os_client_config";
  };

  nativeCheckInputs = [
    fixtures
    jsonschema
    python-subunit
    oslotest
    stestr
    testscenarios
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
    openstacksdk
    pbr
    python-glanceclient
  ];

  pyproject = true;
  pythonImportsCheck = [ "os_client_config" ];

  meta = {
    description = "Unified config handling for client libraries and programs";
    homepage = "https://github.com/openstack/os-client-config";
    license = lib.licenses.asl20;
    teams = [ lib.teams.openstack ];
  };
}
