{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  poetry-core,
  # nativeCheckInputs
  pytestCheckHook,
  # dependencies
  python-yakh,
  rich,
}:

buildPythonPackage rec {
  pname = "questo";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "petereon";
    repo = "questo";
    rev = "v${version}";
    hash = "sha256-1T8HRgIW9P5iX1a75Bn9XqiVMCPtL7tdQTpixPbTbv0=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    poetry-core
  ];

  dependencies = [
    python-yakh
    rich
  ];

  pyproject = true;

  pythonImportsCheck = [
    "questo"
  ];

  meta = {
    description = "Library of extensible and modular CLI prompt elements";
    homepage = "https://github.com/petereon/questo";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
