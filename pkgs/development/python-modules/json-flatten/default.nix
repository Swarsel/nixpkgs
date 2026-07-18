{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "json-flatten";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "json-flatten";
    tag = version;
    hash = "sha256-zAaunWuFAokC16FwHRHgyvq27pNUEGXJfSqTQ1wvXE8=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  pyproject = true;

  pythonImportsCheck = [
    "json_flatten"
  ];

  meta = {
    description = "Functions for flattening a JSON object to a single dictionary of pairs";
    homepage = "https://github.com/simonw/json-flatten";
    changelog = "https://github.com/simonw/json-flatten/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
  };
}
