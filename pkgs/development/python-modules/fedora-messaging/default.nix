{
  lib,
  stdenv,
  fetchFromGitHub,
  # dependencies
  blinker,
  buildPythonPackage,
  click,
  crochet,
  jsonschema,
  pika,
  # build-system
  poetry-core,
  pyopenssl,
  # tests
  pytest-mock,
  pytest-twisted,
  pytestCheckHook,
  requests,
  service-identity,
  tomli,
  twisted,
}:

buildPythonPackage rec {
  pname = "fedora-messaging";
  version = "3.9.1";

  src = fetchFromGitHub {
    owner = "fedora-infra";
    repo = "fedora-messaging";
    tag = "v${version}";
    hash = "sha256-384pvF/MgOReA52bfifa4Fuo79b9zUe+AK7vfIkFSf8=";
  };

  nativeCheckInputs = [
    pytest-mock
    pytest-twisted
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ poetry-core ];

  dependencies = [
    blinker
    click
    crochet
    jsonschema
    pika
    pyopenssl
    requests
    service-identity
    tomli
    twisted
  ];

  disabledTests = [
    # Broken since click was updated to 8.2.1 in https://github.com/NixOS/nixpkgs/pull/448189
    # AssertionError
    "test_no_conf"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # AttributeError: module 'errno' has no attribute 'EREMOTEIO'. Did you mean: 'EREMOTE'?
    "test_publish_rejected_message"
  ];

  enabledTestPaths = [ "tests/unit" ];
  pyproject = true;
  pythonImportsCheck = [ "fedora_messaging" ];

  meta = {
    description = "Library for sending AMQP messages with JSON schema in Fedora infrastructure";
    homepage = "https://github.com/fedora-infra/fedora-messaging";
    changelog = "https://github.com/fedora-infra/fedora-messaging/releases/tag/${src.tag}";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ erictapen ];
  };
}
