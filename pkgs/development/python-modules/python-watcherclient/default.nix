{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cliff,
  keystoneauth1,
  openstackdocstheme,
  osc-lib,
  oslo-i18n,
  oslo-serialization,
  oslo-utils,
  pbr,
  setuptools,
  sphinxHook,
  sphinxcontrib-apidoc,
  stestr,
}:

buildPythonPackage rec {
  pname = "python-watcherclient";
  version = "4.10.0";

  src = fetchFromGitHub {
    owner = "openstack";
    repo = "python-watcherclient";
    tag = version;
    hash = "sha256-TYMV55uvTCvHKj5w5QA2zRqVr6pXCXh2Oc07Yo7epjs=";
  };

  nativeBuildInputs = [
    openstackdocstheme
    sphinxcontrib-apidoc
    sphinxHook
  ];

  env.PBR_VERSION = version;
  nativeCheckInputs = [ stestr ];

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
    cliff
    keystoneauth1
    osc-lib
    oslo-i18n
    oslo-serialization
    oslo-utils
  ];

  pyproject = true;
  pythonImportsCheck = [ "watcherclient" ];
  sphinxBuilders = [ "man" ];

  meta = {
    description = "Client library for OpenStack Watcher API";
    homepage = "https://github.com/openstack/python-watcherclient";
    license = lib.licenses.asl20;
    mainProgram = "watcher";
    teams = [ lib.teams.openstack ];
  };
}
