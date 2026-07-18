{
  lib,
  buildPythonPackage,
  fetchPypi,
  mock,
  pytestCheckHook,
  requests,
  setuptools,
}:
buildPythonPackage rec {
  pname = "pygelf";
  version = "0.4.3";

  src = fetchPypi {
    inherit version;
    hash = "sha256-jtlyVjvjyPFoSD8B2/UitrxpeVnJej9IgTJLP3ljiRE=";
    pname = "pygelf";
  };

  nativeCheckInputs = [
    mock
    pytestCheckHook
    requests
  ];

  build-system = [ setuptools ];

  disabledTestPaths = [
    # The fixtures in these files fail to evaluate due to missing files `tests/config/cert.pem` and
    # `tests/config/key.pem`. It suffices to replace them with any self-signed certificate e.g. from
    # `nixos/tests/common/acme/server/snakeoil-certs.nix`, but after resolving that, all of the
    # tests fail anyway with “ConnectionRefusedError: [Errno 111] Connection refused”.
    "tests/test_common_fields.py"
    "tests/test_debug_mode.py"
    "tests/test_dynamic_fields.py"
    "tests/test_queuehandler_support.py"
    "tests/test_static_fields.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pygelf" ];

  meta = {
    description = "Python logging handlers with GELF (Graylog Extended Log Format) support";
    homepage = "https://github.com/keeprocking/pygelf";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
