{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  jsonschema,
  pytestCheckHook,
  python-dateutil,
  requests,
  setuptools,
  typing-extensions,
  websocket-client,
}:

buildPythonPackage rec {
  pname = "ripe-atlas-cousteau";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "RIPE-NCC";
    repo = "ripe-atlas-cousteau";
    tag = "v${version}";
    hash = "sha256-z8ZXOiCVYughrbmXfnwtks7NPmYpII2BA0+8mr1cdSQ=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    jsonschema
  ];

  build-system = [ setuptools ];

  dependencies = [
    python-dateutil
    requests
    typing-extensions
    websocket-client
  ];

  pyproject = true;
  pythonImportsCheck = [ "ripe.atlas.cousteau" ];
  pythonRelaxDeps = [ "websocket-client" ];

  meta = {
    description = "Python client library for RIPE ATLAS API";
    homepage = "https://github.com/RIPE-NCC/ripe-atlas-cousteau";
    changelog = "https://github.com/RIPE-NCC/ripe-atlas-cousteau/blob/v${version}/CHANGES.rst";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
  };
}
