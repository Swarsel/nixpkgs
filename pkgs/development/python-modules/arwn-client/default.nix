{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  paho-mqtt,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "arwn-client";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "sdague";
    repo = "arwn-client";
    tag = "v${finalAttrs.version}";
    hash = "sha256-By4dZlzR3It4UkYss+RPsKt9Easkegv6VbLd0SSaC2U=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    click
    paho-mqtt
  ];

  pyproject = true;
  pythonImportsCheck = [ "arwn_client" ];

  meta = {
    description = "Python client library for parsing ARWN weather station MQTT messages";
    homepage = "https://github.com/sdague/arwn-client";
    changelog = "https://github.com/sdague/arwn-client/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.jamiemagee ];
    mainProgram = "arwn-client";
  };
})
