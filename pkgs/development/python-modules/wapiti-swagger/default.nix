{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  pyyaml,
  setuptools,
}:

buildPythonPackage rec {
  pname = "wapiti-swagger";
  version = "0.1.9";

  src = fetchFromGitHub {
    owner = "wapiti-scanner";
    repo = "wapiti_swagger";
    tag = version;
    hash = "sha256-On4R5+9+6w8CdZYQ8oxAfuxWTQZotkxjrIf497lETfw=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    pyyaml
  ];

  pyproject = true;
  pythonImportsCheck = [ "wapiti_swagger" ];

  meta = {
    description = "Library for parsing and generating request bodies from Swagger/OpenAPI specifications";
    homepage = "https://github.com/wapiti-scanner/wapiti_swagger";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
