{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  esphome,
  pytestCheckHook,
  setuptools,
}:

let
  testing = fetchFromGitHub {
    hash = "sha256-SQoNdkWMjnasPjpXQF2yV97MUra8gb27pc3rNoA8Rjw=";
    owner = "eclipse";
    repo = "paho.mqtt.testing";
    rev = "a4dc694010217b291ee78ee13a6d1db812f9babd";
  };
in
buildPythonPackage (finalAttrs: {
  pname = "paho-mqtt";
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "eclipse";
    repo = "paho.mqtt.python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9nH6xROVpmI+iTKXfwv2Ar1PAmWbEunI3HO0pZyK6Rg=";
  };

  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
  ];

  preCheck = ''
    ln -s ${testing} paho.mqtt.testing

    # paho.mqtt not in top-level dir to get caught by this
    export PYTHONPATH=".:$PYTHONPATH"
  '';

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  disabledTests = [
    # Fails during teardown
    # RuntimeError: Client 01-zero-length-clientid.py exited with code None, expected 0
    "test_01_zero_length_clientid"
  ];

  pyproject = true;
  pythonImportsCheck = [ "paho.mqtt" ];

  meta = {
    inherit (esphome.meta) maintainers;
    description = "MQTT version 5.0/3.1.1 client class";
    homepage = "https://eclipse.org/paho";
    changelog = "https://github.com/eclipse/paho.mqtt.python/blob/${finalAttrs.src.tag}/ChangeLog.txt";
    license = lib.licenses.epl20;
  };
})
