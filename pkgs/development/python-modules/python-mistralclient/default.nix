{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cliff,
  keystoneauth1,
  openstackdocstheme,
  openstacksdk,
  osc-lib,
  oslo-i18n,
  oslo-serialization,
  oslo-utils,
  oslotest,
  osprofiler,
  pbr,
  pyyaml,
  requests,
  requests-mock,
  setuptools,
  sphinxHook,
  sphinxcontrib-apidoc,
  stestr,
  stevedore,
  tempest,
}:

buildPythonPackage rec {
  pname = "python-mistralclient";
  version = "6.2.0";

  src = fetchFromGitHub {
    owner = "openstack";
    repo = "python-mistralclient";
    tag = version;
    hash = "sha256-FNfee7d8gTcsTdv7lxqDbniUiKQvUXHRSkAlNOCn/k4=";
  };

  nativeBuildInputs = [
    openstackdocstheme
    sphinxHook
    sphinxcontrib-apidoc
  ];

  env.PBR_VERSION = version;

  nativeCheckInputs = [
    openstacksdk
    oslotest
    osprofiler
    requests-mock
    stestr
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
    keystoneauth1
    osc-lib
    oslo-i18n
    oslo-serialization
    oslo-utils
    pbr
    pyyaml
    requests
    stevedore
  ];

  pyproject = true;
  pythonImportsCheck = [ "mistralclient" ];
  sphinxBuilders = [ "man" ];

  meta = {
    description = "OpenStack Mistral Command-line Client";
    homepage = "https://opendev.org/openstack/python-mistralclient/";
    license = lib.licenses.asl20;
    mainProgram = "mistral";
    teams = [ lib.teams.openstack ];
  };
}
