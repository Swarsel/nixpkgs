{
  lib,
  buildPythonPackage,
  callPackage,
  cliff,
  fetchPypi,
  keystoneauth1,
  openstackdocstheme,
  osc-lib,
  oslo-serialization,
  oslo-utils,
  pbr,
  requests,
  setuptools,
  sphinx,
  sphinxcontrib-apidoc,
}:

buildPythonPackage rec {
  pname = "python-octaviaclient";
  version = "3.13.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Iq1TdXMUDqrE33V+yh8H7yYPIW01NVEa6cPqFPq4Yv4=";
    pname = "python_octaviaclient";
  };

  nativeBuildInputs = [
    openstackdocstheme
    sphinx
    sphinxcontrib-apidoc
  ];

  # Checks moved to 'passthru.tests' to workaround infinite recursion
  doCheck = false;

  build-system = [
    setuptools
    pbr
  ];

  dependencies = [
    cliff
    keystoneauth1
    osc-lib
    oslo-serialization
    oslo-utils
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "octaviaclient" ];
  # NOTE(vinetos): This explicit dependency is removed to avoid infinite recursion
  pythonRemoveDeps = [ "python-openstackclient" ];

  passthru.tests = {
    tests = callPackage ./tests.nix { };
  };

  meta = {
    description = "OpenStack Octavia Command-line Client";
    homepage = "https://github.com/openstack/python-octaviaclient";
    license = lib.licenses.asl20;
    teams = [ lib.teams.openstack ];
  };
}
