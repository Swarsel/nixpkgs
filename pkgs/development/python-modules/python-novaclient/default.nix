{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  coverage,
  fixtures,
  iso8601,
  # direct
  keystoneauth1,
  openssl,
  openstackdocstheme,
  openstacksdk,
  oslo-i18n,
  oslo-serialization,
  oslo-utils,
  osprofiler,
  pbr,
  prettytable,
  requests-mock,
  setuptools,
  # docs
  sphinxHook,
  sphinxcontrib-apidoc,
  # tests
  stestrCheckHook,
  stevedore,
  tempest,
  testscenarios,
  testtools,
  versionCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-novaclient";
  version = "18.12.0";

  src = fetchFromGitHub {
    owner = "openstack";
    repo = "python-novaclient";
    tag = finalAttrs.version;
    hash = "sha256-ZVJXGGceY7tnD/rkMkZjn5zifATeLYRGEVI2iLKERJ8=";
  };

  patches = [
    ./fix-setup-cfg.patch
  ];

  nativeBuildInputs = [
    openstackdocstheme
    sphinxcontrib-apidoc
    sphinxHook
  ];

  env.PBR_VERSION = finalAttrs.version;

  nativeCheckInputs = [
    stestrCheckHook
    coverage
    fixtures
    requests-mock
    openstacksdk
    osprofiler
    openssl
    testscenarios
    testtools
    tempest
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  build-system = [
    pbr
    setuptools
  ];

  dependencies = [
    keystoneauth1
    iso8601
    oslo-i18n
    oslo-serialization
    oslo-utils
    pbr
    prettytable
    stevedore
  ];

  pyproject = true;

  pythonImportsCheck = [
    "novaclient"
    "novaclient.v2"
    "novaclient.tests"
    "novaclient.tests.functional"
    "novaclient.tests.functional.api"
    "novaclient.tests.functional.v2"
    "novaclient.tests.functional.v2.legacy"
    "novaclient.tests.unit"
    "novaclient.tests.unit.fixture_data"
    "novaclient.tests.unit.v2"
  ];

  sphinxBuilders = [ "man" ];

  meta = {
    description = "Client library for OpenStack Compute API";
    homepage = "https://docs.openstack.org/python-novaclient/latest/";
    license = lib.licenses.asl20;
    mainProgram = "nova";
    downloadPage = "https://github.com/openstack/python-novaclient/releases/tag/${finalAttrs.src.tag}";
    teams = [ lib.teams.openstack ];
  };
})
