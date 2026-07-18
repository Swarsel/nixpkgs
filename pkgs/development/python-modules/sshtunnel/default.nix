{
  lib,
  buildPythonPackage,
  fetchPypi,
  mock,
  paramiko,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "sshtunnel";
  version = "0.4.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-58sOp3Tbgb+RhE2yLecqQKro97D5u5ug9mbUdO9r+fw=";
  };

  # https://github.com/pahaz/sshtunnel/pull/301
  patches = [ ./paramiko-4.0-compat.patch ];

  nativeCheckInputs = [
    pytestCheckHook
    mock
  ];

  build-system = [ setuptools ];
  dependencies = [ paramiko ];

  # disable impure tests
  disabledTests = [
    "test_get_keys"
    "connect_via_proxy"
    "read_ssh_config"
    # Test doesn't work with paramiko < 4.0.0 and the patch above
    "test_read_private_key_file"
  ];

  pyproject = true;

  meta = {
    description = "Pure python SSH tunnels";
    homepage = "https://github.com/pahaz/sshtunnel";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "sshtunnel";
  };
}
