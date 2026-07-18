{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # direct
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
  pifpaf,
  pyparsing,
  setuptools,
  # docs
  sphinxHook,
  # tests
  stestrCheckHook,
  tempest,
  testtools,
  versionCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-aodhclient";
  version = "3.10.1";

  src = fetchFromGitHub {
    owner = "openstack";
    repo = "python-aodhclient";
    tag = finalAttrs.version;
    hash = "sha256-xm42ZicdBxxm4LTDHPhEIeNU6evBZtp2PGvGy6V2t8c=";
  };

  patches = [
    ./fix-pyproject.patch
  ];

  nativeBuildInputs = [
    openstackdocstheme
    sphinxHook
  ];

  env.PBR_VERSION = finalAttrs.version;

  nativeCheckInputs = [
    stestrCheckHook
    openstacksdk
    oslotest
    tempest
    testtools
    pifpaf
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

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
    osprofiler
    pbr
    pyparsing
  ];

  pyproject = true;

  pythonImportsCheck = [
    "aodhclient"
    "aodhclient.v2"
    "aodhclient.tests"
    "aodhclient.tests.functional"
    "aodhclient.tests.unit"
  ];

  sphinxBuilders = [ "man" ];

  meta = {
    description = "Client library for OpenStack AOodh API";
    homepage = "https://docs.openstack.org/python-aodhclient/latest/";
    license = lib.licenses.asl20;
    mainProgram = "aodh";
    downloadPage = "https://github.com/openstack/python-aodhclientz /releases/tag/${finalAttrs.src.tag}";
    teams = [ lib.teams.openstack ];
  };
})
