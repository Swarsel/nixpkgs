{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:
buildPythonPackage rec {
  pname = "condense-json";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "condense-json";
    tag = version;
    hash = "sha256-vMh6GLWqae0Ave3FmrGQuVCgFzYMGCIe76mGNDMrBdU=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "condense_json" ];

  meta = {
    description = "Python function for condensing JSON using replacement strings";
    homepage = "https://github.com/simonw/condense-json";
    changelog = "https://github.com/simonw/condense-json/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ josh ];
  };
}
