{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  ddt,
  jsonschema,
  keystoneauth1,
  openstackdocstheme,
  osc-lib,
  oslo-i18n,
  oslo-log,
  oslo-utils,
  pbr,
  requests,
  requests-mock,
  setuptools,
  sphinxHook,
  stestr,
  stevedore,
}:

buildPythonPackage rec {
  pname = "python-zaqarclient";
  version = "4.4.0";

  src = fetchFromGitHub {
    owner = "openstack";
    repo = "python-zaqarclient";
    tag = version;
    hash = "sha256-bxB6f3HgTPeMkMYg+yEzkgHBkXPb6UMuKBo9XC74O/U=";
  };

  nativeBuildInputs = [
    openstackdocstheme
    sphinxHook
  ];

  env.PBR_VERSION = version;

  nativeCheckInputs = [
    ddt
    requests-mock
    stestr
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
    jsonschema
    keystoneauth1
    osc-lib
    oslo-i18n
    oslo-log
    oslo-utils
    requests
    stevedore
  ];

  pyproject = true;
  pythonImportsCheck = [ "zaqarclient" ];
  sphinxBuilders = [ "man" ];

  meta = {
    description = "Client library for OpenStack Zaqar API";
    homepage = "https://github.com/openstack/python-zaqarclient";
    license = lib.licenses.asl20;
    teams = [ lib.teams.openstack ];
  };
}
