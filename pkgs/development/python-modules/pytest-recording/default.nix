{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # test dependencies
  hatchling,
  # install dependencies
  pytest,
  pytest-httpbin,
  pytest-mock,
  pytestCheckHook,
  requests,
  vcrpy,
}:

buildPythonPackage rec {
  pname = "pytest-recording";
  version = "0.13.4";

  src = fetchFromGitHub {
    owner = "kiwicom";
    repo = "pytest-recording";
    tag = "v${version}";
    hash = "sha256-S++MnI0GgpQxS6kFkt05kcE4JMW7jyFjJ3o7DhfYoVA=";
  };

  buildInputs = [
    pytest
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-httpbin
    pytest-mock
    requests
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ hatchling ];
  dependencies = [ vcrpy ];

  disabledTests = [
    "test_block_network_with_allowed_hosts"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # Missing socket.AF_NETLINK
    "test_other_socket"
  ];

  enabledTestPaths = [ "tests" ];
  pyproject = true;
  pythonImportsCheck = [ "pytest_recording" ];

  meta = {
    description = "Pytest plugin that allows you recording of network interactions via VCR.py";
    homepage = "https://github.com/kiwicom/pytest-recording";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jbgosselin ];
  };
}
