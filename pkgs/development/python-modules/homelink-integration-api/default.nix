{
  lib,
  fetchFromGitHub,
  aiofiles,
  aiohttp,
  boto3,
  buildPythonPackage,
  paho-mqtt,
  pyopenssl,
  python-decouple,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "homelink-integration-api";
  version = "0.0.5";

  src = fetchFromGitHub {
    owner = "Gentex-Corporation";
    repo = "homelink-integration-api";
    tag = "v${finalAttrs.version}";
    hash = "sha256-N46c7SgEUQUs2UlNVjcCLpNBpUNI4WPDydl3gB+jmag=";
  };

  # upstream tests require network access and AWS credentials
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiofiles
    aiohttp
    boto3
    paho-mqtt
    pyopenssl
    python-decouple
  ];

  pyproject = true;
  pythonImportsCheck = [ "homelink" ];

  meta = {
    description = "API to interact with Homelink cloud for MQTT-enabled smart home platforms";
    homepage = "https://github.com/Gentex-Corporation/homelink-integration-api";
    changelog = "https://github.com/Gentex-Corporation/homelink-integration-api/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
