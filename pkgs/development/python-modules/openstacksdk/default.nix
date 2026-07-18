{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  callPackage,
  # direct
  cryptography,
  dogpile-cache,
  jmespath,
  jsonpatch,
  keystoneauth1,
  munch,
  openstackdocstheme,
  os-service-types,
  pbr,
  platformdirs,
  psutil,
  pyyaml,
  setuptools,
  # docs
  sphinxHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "openstacksdk";
  version = "4.13.0";

  src = fetchFromGitHub {
    owner = "openstack";
    repo = "openstacksdk";
    tag = finalAttrs.version;
    hash = "sha256-nMpUNLz7OosoGd5rozWcOcOEf3jdEHo5dhxmOv0xONw=";
  };

  outputs = [
    "out"
    "man"
  ];

  patches = [
    ./fix-pyproject.patch
  ];

  postPatch = ''
    # Disable rsvgconverter not needed to build manpage
    substituteInPlace doc/source/conf.py \
      --replace-fail "'sphinxcontrib.rsvgconverter'," "#'sphinxcontrib.rsvgconverter',"
  '';

  nativeBuildInputs = [
    openstackdocstheme
    sphinxHook
  ];

  env.PBR_VERSION = finalAttrs.version;
  # Checks moved to 'passthru.tests' to workaround slowness
  doCheck = false;

  build-system = [
    pbr
    setuptools
  ];

  dependencies = [
    platformdirs
    cryptography
    dogpile-cache
    jmespath
    jsonpatch
    keystoneauth1
    munch
    os-service-types
    psutil
    pyyaml
  ];

  pyproject = true;

  # Non-exhaustive imports
  pythonImportsCheck = [
    "openstack"
    "openstack.config.loader"
    "openstack.compute.v2.server"
    "openstack.test"
  ];

  sphinxBuilders = [ "man" ];

  passthru.tests = {
    tests = callPackage ./tests.nix { };
  };

  meta = {
    description = "SDK for building applications to work with OpenStack clouds.";
    homepage = "https://docs.openstack.org/openstacksdk/latest/";
    license = lib.licenses.asl20;
    mainProgram = "openstack";
    downloadPage = "https://github.com/openstack/openstacksdk/releases/tag/${finalAttrs.src.tag}";
    teams = [ lib.teams.openstack ];
  };
})
