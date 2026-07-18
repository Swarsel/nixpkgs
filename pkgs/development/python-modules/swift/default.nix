{
  lib,
  boto3,
  buildPythonPackage,
  cryptography,
  eventlet,
  fetchPypi,
  greenlet,
  iana-etc,
  installShellFiles,
  libredirect,
  lxml,
  mock,
  pastedeploy,
  pbr,
  pyeclib,
  requests,
  setuptools,
  six,
  stestr,
  swiftclient,
  xattr,
}:

buildPythonPackage (finalAttrs: {
  pname = "swift";
  version = "2.37.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-d5Jol5iCY8o+Ix+xrviufMLOh3T0UN2bVa+GrsA8D6k=";
  };

  nativeBuildInputs = [ installShellFiles ];
  # a lot of tests currently fail while establishing a connection
  doCheck = false;

  nativeCheckInputs = [
    boto3
    libredirect.hook
    mock
    stestr
    swiftclient
  ];

  checkPhase = ''
    echo "nameserver 127.0.0.1" > resolv.conf
    export NIX_REDIRECTS=/etc/protocols=${iana-etc}/etc/protocols:/etc/resolv.conf=$(realpath resolv.conf)

    export SWIFT_TEST_CONFIG_FILE=test/sample.conf

    stestr run
  '';

  postInstall = ''
    installManPage doc/manpages/*
  '';

  build-system = [
    pbr
    setuptools
  ];

  dependencies = [
    cryptography
    eventlet
    greenlet
    lxml
    pastedeploy
    pyeclib
    requests
    six
    xattr
  ];

  pyproject = true;
  pythonImportsCheck = [ "swift" ];

  meta = {
    description = "OpenStack Object Storage";
    homepage = "https://github.com/openstack/swift";
    license = lib.licenses.asl20;
    teams = [ lib.teams.openstack ];
  };
})
