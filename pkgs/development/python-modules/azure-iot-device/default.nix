{
  lib,
  buildPythonPackage,
  deprecation,
  fetchPypi,
  janus,
  paho-mqtt,
  pysocks,
  requests,
  requests-unixsocket2,
  setuptools,
  typing-extensions,
  urllib3,
}:
buildPythonPackage rec {
  pname = "azure-iot-device";
  version = "2.14.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-ttSNSTLCQAJXNqzlRMTnG8SaFXasmY6h3neK+CSW/84=";
    pname = "azure_iot_device";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    urllib3
    deprecation
    paho-mqtt
    requests
    requests-unixsocket2
    janus
    pysocks
    typing-extensions
  ];

  # Module has no tests
  doCheck = false;
  pyproject = true;

  pythonImportsCheck = [
    "azure.iot.device"
    "azure.iot.device.aio"
  ];

  meta = {
    description = "Microsoft Azure IoT Device Library for Python";
    homepage = "https://github.com/Azure/azure-iot-sdk-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mikut ];
    # https://github.com/Azure/azure-iot-sdk-python/issues/1196
    broken = lib.versionAtLeast paho-mqtt.version "2";
  };
}
