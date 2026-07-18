{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  docker,
  keystoneauth1,
  openstackdocstheme,
  osc-lib,
  oslo-i18n,
  oslo-log,
  oslo-utils,
  pbr,
  prettytable,
  setuptools,
  sphinxHook,
  stestr,
  websocket-client,
}:

buildPythonPackage rec {
  pname = "python-zunclient";
  version = "5.4.0";

  src = fetchFromGitHub {
    owner = "openstack";
    repo = "python-zunclient";
    tag = version;
    hash = "sha256-Ps4V05obkbiy4dbPBOff3WQ1d502Ie303jAmtatNOdc=";
  };

  nativeBuildInputs = [
    openstackdocstheme
    sphinxHook
  ];

  env.PBR_VERSION = version;
  nativeCheckInputs = [ stestr ];

  checkPhase = ''
    runHook preCheck
    stestr run -e <(echo "
      zunclient.tests.unit.test_shell.ShellTest.test_main_endpoint_internal
      zunclient.tests.unit.test_shell.ShellTest.test_main_endpoint_public
      zunclient.tests.unit.test_shell.ShellTest.test_main_env_region
      zunclient.tests.unit.test_shell.ShellTest.test_main_no_region
      zunclient.tests.unit.test_shell.ShellTest.test_main_option_region
      zunclient.tests.unit.test_shell.ShellTestKeystoneV3.test_main_endpoint_internal
      zunclient.tests.unit.test_shell.ShellTestKeystoneV3.test_main_endpoint_public
      zunclient.tests.unit.test_shell.ShellTestKeystoneV3.test_main_env_region
      zunclient.tests.unit.test_shell.ShellTestKeystoneV3.test_main_no_region
      zunclient.tests.unit.test_shell.ShellTestKeystoneV3.test_main_option_region
    ")
    runHook postCheck
  '';

  build-system = [
    pbr
    setuptools
  ];

  dependencies = [
    docker
    keystoneauth1
    osc-lib
    oslo-i18n
    oslo-log
    oslo-utils
    prettytable
    websocket-client
  ];

  pyproject = true;
  pythonImportsCheck = [ "zunclient" ];
  # python-openstackclient is unused upstream
  # and will cause infinite recursion in openstackclient-full package.
  pythonRemoveDeps = [ "python-openstackclient" ];
  sphinxBuilders = [ "man" ];

  meta = {
    description = "Client library for OpenStack Zun API";
    homepage = "https://github.com/openstack/python-zunclient";
    license = lib.licenses.asl20;
    mainProgram = "zun";
    teams = [ lib.teams.openstack ];
  };
}
