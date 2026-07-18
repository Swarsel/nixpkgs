{
  lib,
  stdenv,
  automat,
  buildPythonPackage,
  cryptography,
  fetchPypi,
  geoip,
  lsof,
  mock,
  pytestCheckHook,
  setuptools,
  twisted,
  zope-interface,
}:

buildPythonPackage rec {
  pname = "txtorcon";
  version = "26.6.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-BAjwY6n8uN9Snayle7c3PqD1tOuv/NUQN1S3xWF3P2g=";
  };

  doCheck = !(stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64);

  nativeCheckInputs = [
    pytestCheckHook
    mock
    lsof
    geoip
  ];

  build-system = [ setuptools ];

  dependencies = [
    cryptography
    twisted
    automat
    zope-interface
  ]
  ++ twisted.optional-dependencies.tls;

  pyproject = true;
  pythonImportsCheck = [ "txtorcon" ];

  meta = {
    description = "Twisted-based Tor controller client, with state-tracking and configuration abstractions";
    homepage = "https://github.com/meejah/txtorcon";
    changelog = "https://github.com/meejah/txtorcon/releases/tag/v${version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      jluttine
      exarkun
    ];
  };
}
