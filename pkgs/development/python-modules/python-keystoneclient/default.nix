{
  lib,
  buildPythonPackage,
  fetchPypi,
  keystoneauth1,
  openssl,
  oslo-config,
  oslo-serialization,
  pbr,
  requests-mock,
  setuptools,
  stestr,
  testresources,
  testscenarios,
}:

buildPythonPackage rec {
  pname = "python-keystoneclient";
  version = "5.8.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-PKh8Z8QEKYzoYjELVp9UWlis91zVaFCUyC81Mgs6NV0=";
    pname = "python_keystoneclient";
  };

  nativeCheckInputs = [
    openssl
    requests-mock
    stestr
    testresources
    testscenarios
  ];

  checkPhase = ''
    runHook preCheck
    stestr run
    runHook postCheck
  '';

  build-system = [ setuptools ];

  dependencies = [
    keystoneauth1
    oslo-config
    oslo-serialization
    pbr
  ];

  pyproject = true;
  pythonImportsCheck = [ "keystoneclient" ];

  meta = {
    description = "Client Library for OpenStack Identity";
    homepage = "https://github.com/openstack/python-keystoneclient";
    license = lib.licenses.asl20;
    teams = [ lib.teams.openstack ];
  };
}
