{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  httplib2,
  keystoneauth1,
  openstackdocstheme,
  osc-lib,
  oslo-i18n,
  oslo-utils,
  pbr,
  prettytable,
  python-mistralclient,
  python-openstackclient,
  python-swiftclient,
  requests,
  requests-mock,
  setuptools,
  sphinxHook,
  sphinxcontrib-apidoc,
  stestr,
  stevedore,
}:

buildPythonPackage rec {
  pname = "python-troveclient";
  version = "8.10.0";

  src = fetchFromGitHub {
    owner = "openstack";
    repo = "python-troveclient";
    tag = version;
    hash = "sha256-ayNRhT337eG6NJM2ugAqiH6st+2s4gySIeNQ4jJb8nU=";
  };

  nativeBuildInputs = [
    openstackdocstheme
    sphinxHook
    sphinxcontrib-apidoc
  ];

  env.PBR_VERSION = version;

  nativeCheckInputs = [
    httplib2
    requests-mock
    stestr
  ];

  checkPhase = ''
    runHook preCheck
    stestr run -e <(echo "
    troveclient.tests.test_shell.ShellTest.test_help
    troveclient.tests.test_shell.ShellTestKeystoneV3.test_help
    ")
    runHook postCheck
  '';

  build-system = [
    pbr
    setuptools
  ];

  dependencies = [
    keystoneauth1
    osc-lib
    oslo-i18n
    oslo-utils
    prettytable
    python-mistralclient
    python-openstackclient
    python-swiftclient
    requests
    stevedore
  ];

  pyproject = true;
  pythonImportsCheck = [ "troveclient" ];
  sphinxBuilders = [ "man" ];

  meta = {
    description = "Client library for OpenStack Trove API";
    homepage = "https://github.com/openstack/python-troveclient";
    license = lib.licenses.asl20;
    mainProgram = "trove";
    teams = [ lib.teams.openstack ];
  };
}
