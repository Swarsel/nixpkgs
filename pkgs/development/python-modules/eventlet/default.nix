{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  dnspython,
  greenlet,
  # build-system
  hatch-vcs,
  hatchling,
  # tests
  iana-etc,
  isPyPy,
  libredirect,
  pytestCheckHook,
  six,
}:

buildPythonPackage rec {
  pname = "eventlet";
  version = "0.40.3";

  src = fetchFromGitHub {
    owner = "eventlet";
    repo = "eventlet";
    tag = version;
    hash = "sha256-yieyNx91jvKoh02zDFIEFk70yf3I27DWiumqoOjtdzQ=";
  };

  # tests hang on pypy indefinitely
  # most tests also fail/flake on Darwin
  doCheck = !isPyPy && !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    libredirect.hook
    pytestCheckHook
  ];

  preCheck = lib.optionalString doCheck ''
    echo "nameserver 127.0.0.1" > resolv.conf
    export NIX_REDIRECTS=/etc/protocols=${iana-etc}/etc/protocols:/etc/resolv.conf=$(realpath resolv.conf)

    export EVENTLET_IMPORT_VERSION_ONLY=0
  '';

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    dnspython
    greenlet
    six
  ];

  disabledTests = [
    # AssertionError: Expected single line "pass" in stdout
    "test_fork_after_monkey_patch"
    # Tests requires network access
    "test_getaddrinfo"
    "test_hosts_no_network"
    # flaky test, depends on builder performance
    "test_server_connection_timeout_exception"
    # broken with openssl 3.4
    "test_ssl_close"
    # flaky test
    "test_send_timeout"
  ];

  pyproject = true;
  pythonImportsCheck = [ "eventlet" ];
  pythonRelaxDeps = lib.optionals isPyPy [ "greenlet" ];

  meta = {
    description = "Concurrent networking library for Python";
    homepage = "https://github.com/eventlet/eventlet/";
    changelog = "https://github.com/eventlet/eventlet/blob/${src.tag}/NEWS";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
}
