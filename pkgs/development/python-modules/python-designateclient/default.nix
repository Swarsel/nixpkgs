{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  debtcollector,
  jsonschema,
  keystoneauth1,
  openstackdocstheme,
  osc-lib,
  oslo-serialization,
  oslo-utils,
  oslotest,
  pbr,
  requests,
  requests-mock,
  setuptools,
  sphinxHook,
  sphinxcontrib-apidoc,
  stestr,
}:

buildPythonPackage rec {
  pname = "python-designateclient";
  version = "6.4.0";

  src = fetchFromGitHub {
    owner = "openstack";
    repo = "python-designateclient";
    tag = version;
    hash = "sha256-OBvPdulj2lg2FCyMDOp1iw12MxLre0/jkMdc7syJatc=";
  };

  nativeBuildInputs = [
    openstackdocstheme
    sphinxHook
    sphinxcontrib-apidoc
  ];

  env.PBR_VERSION = version;

  nativeCheckInputs = [
    oslotest
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
    debtcollector
    jsonschema
    keystoneauth1
    osc-lib
    oslo-serialization
    oslo-utils
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "designateclient" ];
  sphinxBuilders = [ "man" ];

  meta = {
    description = "Client library for OpenStack Designate API";
    homepage = "https://opendev.org/openstack/python-designateclient";
    license = lib.licenses.asl20;
    teams = [ lib.teams.openstack ];
  };
}
