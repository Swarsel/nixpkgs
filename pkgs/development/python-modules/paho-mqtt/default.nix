{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  openssl,
  pytestCheckHook,
}:

let
  testing = fetchFromGitHub {
    hash = "sha256-SQoNdkWMjnasPjpXQF2yV97MUra8gb27pc3rNoA8Rjw=";
    owner = "eclipse";
    repo = "paho.mqtt.testing";
    rev = "a4dc694010217b291ee78ee13a6d1db812f9babd";
  };
in
buildPythonPackage rec {
  pname = "paho-mqtt";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "eclipse";
    repo = "paho.mqtt.python";
    rev = "v${version}";
    hash = "sha256-VMq+WTW+njK34QUUTE6fR2j2OmHxVzR0wrC92zYb1rY=";
  };

  postPatch = ''
    substituteInPlace tests/ssl/gen.sh \
      --replace-fail "c_rehash certs" "#c_rehash certs"
  '';

  nativeCheckInputs = [
    openssl
    pytestCheckHook
  ];

  preCheck = ''
    ln -s ${testing} paho.mqtt.testing

    # paho.mqtt not in top-level dir to get caught by this
    export PYTHONPATH=".:$PYTHONPATH"

    pushd tests/ssl
    HOME="$(mktemp -d)" ./gen.sh
    popd
  '';

  __darwinAllowLocalNetworking = true;

  build-system = [
    hatchling
  ];

  disabledTests = [
    # Fails during teardown
    # RuntimeError: Client 01-zero-length-clientid.py exited with code None, expected 0
    "test_01_zero_length_clientid"
  ];

  pyproject = true;
  pythonImportsCheck = [ "paho.mqtt" ];

  meta = {
    description = "MQTT version 5.0/3.1.1 client class";
    homepage = "https://eclipse.org/paho";
    changelog = "https://github.com/eclipse/paho.mqtt.python/blob/${src.rev}/ChangeLog.txt";
    license = lib.licenses.epl20;

    maintainers = with lib.maintainers; [
      mog
      dotlambda
    ];
  };
}
