{
  lib,
  fetchFromGitHub,
  anyio,
  buildPythonPackage,
  hatchling,
  paho-mqtt,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "aiomqtt";
  version = "2.5.1";

  src = fetchFromGitHub {
    owner = "sbtinstruments";
    repo = "aiomqtt";
    tag = "v${version}";
    hash = "sha256-f9m+mdlSADOixsKymxsKiVxgWF7JBc3kjVU+rOkC+yM=";
  };

  nativeCheckInputs = [
    anyio
    pytestCheckHook
  ];

  build-system = [ hatchling ];
  dependencies = [ paho-mqtt ];

  disabledTestMarks = [
    "network"
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiomqtt" ];

  meta = {
    description = "Idiomatic asyncio MQTT client, wrapped around paho-mqtt";
    homepage = "https://github.com/sbtinstruments/aiomqtt";
    changelog = "https://github.com/sbtinstruments/aiomqtt/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
