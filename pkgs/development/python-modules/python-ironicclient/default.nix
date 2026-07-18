{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cliff,
  dogpile-cache,
  jsonschema,
  keystoneauth1,
  openstackdocstheme,
  openstacksdk,
  osc-lib,
  oslo-utils,
  oslotest,
  pbr,
  platformdirs,
  pyyaml,
  requests,
  requests-mock,
  setuptools,
  sphinxHook,
  sphinxcontrib-apidoc,
  stestr,
  stevedore,
}:

buildPythonPackage rec {
  pname = "python-ironicclient";
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "openstack";
    repo = "python-ironicclient";
    tag = version;
    hash = "sha256-AbxzRpyfplR4Mk9CcaRXi+CNo08tlRIxAFxsJjrkxvY=";
  };

  env.PBR_VERSION = version;

  nativeCheckInputs = [
    stestr
    requests-mock
    oslotest
  ];

  checkPhase = ''
    runHook preCheck
    stestr run -e <(echo "
      ironicclient.tests.unit.osc.v1.test_baremetal_chassis.TestChassisCreate.test_chassis_create_no_options
      ironicclient.tests.unit.osc.v1.test_baremetal_chassis.TestChassisCreate.test_chassis_create_with_description
      ironicclient.tests.unit.osc.v1.test_baremetal_chassis.TestChassisCreate.test_chassis_create_with_extra
      ironicclient.tests.unit.osc.v1.test_baremetal_chassis.TestChassisCreate.test_chassis_create_with_uuid
      ironicclient.tests.unit.osc.v1.test_baremetal_conductor.TestBaremetalConductorShow.test_conductor_show
      ironicclient.tests.unit.osc.v1.test_baremetal_node.TestBaremetalCreate
      ironicclient.tests.unit.osc.v1.test_baremetal_node.TestBaremetalShow.test_baremetal_show
      ironicclient.tests.unit.osc.v1.test_baremetal_node.TestNodeHistoryEventGet.test_baremetal_node_history_list
    ")
    runHook postCheck
  '';

  build-system = [
    openstackdocstheme
    setuptools
    sphinxcontrib-apidoc
    sphinxHook
  ];

  dependencies = [
    cliff
    dogpile-cache
    jsonschema
    keystoneauth1
    openstacksdk
    osc-lib
    oslo-utils
    pbr
    platformdirs
    pyyaml
    requests
    stevedore
  ];

  pyproject = true;
  pythonImportsCheck = [ "ironicclient" ];
  sphinxBuilders = [ "man" ];

  meta = {
    description = "Client for OpenStack bare metal provisioning API, includes a Python module (ironicclient) and CLI (baremetal)";
    homepage = "https://github.com/openstack/python-ironicclient";
    license = lib.licenses.asl20;
    mainProgram = "baremetal";
    teams = [ lib.teams.openstack ];
  };
}
