{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  keystoneauth1,
  openstackdocstheme,
  osc-lib,
  oslo-serialization,
  oslo-utils,
  oslotest,
  pbr,
  setuptools,
  sphinxHook,
  stestr,
}:

buildPythonPackage rec {
  pname = "osc-placement";
  version = "4.8.0";

  src = fetchFromGitHub {
    owner = "openstack";
    repo = "osc-placement";
    tag = version;
    hash = "sha256-txxLtg3fDrkPqU0k/PlwvpJJBzVLtJXz82mhPWo+rKc=";
  };

  nativeBuildInputs = [
    openstackdocstheme
    sphinxHook
  ];

  env.PBR_VERSION = version;

  nativeCheckInputs = [
    oslo-serialization
    oslotest
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
    keystoneauth1
    osc-lib
    oslo-utils
    pbr
  ];

  pyproject = true;
  pythonImportsCheck = [ "osc_placement" ];
  sphinxBuilders = [ "man" ];

  meta = {
    description = "OpenStackClient plugin for the Placement service";
    homepage = "https://github.com/openstack/osc-placement";
    license = lib.licenses.asl20;
    teams = [ lib.teams.openstack ];
  };
}
