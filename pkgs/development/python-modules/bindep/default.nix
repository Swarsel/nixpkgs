{
  lib,
  buildPythonPackage,
  distro,
  fetchPypi,
  fixtures,
  libredirect,
  packaging,
  parsley,
  pbr,
  pytestCheckHook,
  testtools,
}:

buildPythonPackage rec {
  pname = "bindep";
  version = "2.14.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-DIBMfkjdF9skyzkSGt5xcfaE+0Y8iqAdAzjNEdJUNko=";
  };

  env.PBR_VERSION = version;

  nativeCheckInputs = [
    fixtures
    libredirect.hook
    pytestCheckHook
    testtools
  ];

  preCheck = ''
    echo "ID=nixos
    " > os-release
    export NIX_REDIRECTS=/etc/os-release=$(realpath os-release)
    export PATH=$PATH:$out/bin
  '';

  build-system = [
    pbr
  ];

  dependencies = [
    parsley
    pbr
    packaging
    distro
  ];

  pyproject = true;
  pytestFlags = [ "-s" ];
  pythonImportsCheck = [ "bindep" ];

  meta = {
    description = "Bindep is a tool for checking the presence of binary packages needed to use an application / library";
    homepage = "https://opendev.org/opendev/bindep";
    license = lib.licenses.asl20;
    mainProgram = "bindep";
    teams = [ lib.teams.openstack ];
  };
}
