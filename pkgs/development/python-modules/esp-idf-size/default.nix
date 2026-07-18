{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  distutils,
  # tests
  esptool,
  jsonschema,
  pytestCheckHook,
  # dependencies
  pyyaml,
  rich,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "esp-idf-size";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "espressif";
    repo = "esp-idf-size";
    tag = "v${version}";
    hash = "sha256-kjGO9uLj7/k8WCH6mARFOI4r8IhH/urGKR/23waaOFo=";
  };

  patches = [
    # add back --ng flag as a stub to argparser for compat reason
    ./1.x-compat.patch
  ];

  doCheck = false; # requires ESP-IDF

  nativeCheckInputs = [
    distutils
    esptool
    jsonschema
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    pyyaml
    rich
  ];

  pyproject = true;

  pythonImportsCheck = [
    "esp_idf_size"
  ];

  meta = {
    description = "";
    homepage = "https://github.com/espressif/esp-idf-size";
    changelog = "https://github.com/espressif/esp-idf-size/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
