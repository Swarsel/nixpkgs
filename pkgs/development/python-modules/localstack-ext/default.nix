{
  lib,
  buildPythonPackage,
  click,
  dill,
  dnslib,
  dnspython,
  fetchPypi,
  # use for testing promoted localstack
  pkgs,
  plux,
  pyaes,
  pyjwt,
  pyotp,
  python-dateutil,
  python-jose,
  pyyaml,
  requests,
  rich,
  semver,
  setuptools,
  setuptools-scm,
  tabulate,
}:

buildPythonPackage rec {
  pname = "localstack-ext";
  version = "4.12.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-AQrG6iRTBarinrGgJeLr5OYguuN7KWyxRUYNMHz4mlE=";
    pname = "localstack_ext";
  };

  # No tests in repo
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    click
    dill
    dnslib
    dnspython
    plux
    pyaes
    pyjwt
    pyotp
    python-dateutil
    python-jose
    pyyaml
    requests
    rich
    tabulate
    semver
  ]
  ++ python-jose.optional-dependencies.cryptography;

  pyproject = true;
  pythonImportsCheck = [ "localstack" ];

  pythonRemoveDeps = [
    # Avoid circular dependency
    "localstack"
    "build"
  ];

  passthru.tests = {
    inherit (pkgs) localstack;
  };

  meta = {
    description = "Extensions for LocalStack";
    homepage = "https://github.com/localstack/localstack";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
