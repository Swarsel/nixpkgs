{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  requests,
  responses,
  setuptools,
}:

buildPythonPackage rec {
  pname = "herepy";
  version = "3.6.5";

  src = fetchFromGitHub {
    owner = "abdullahselek";
    repo = "HerePy";
    tag = version;
    hash = "sha256-8DwzzC0sTrGnMpuADc55HCIeH/KyWacv8X+Ubh+n7ZM=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    responses
  ];

  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "herepy" ];

  meta = {
    description = "Library that provides a Python interface to the HERE APIs";
    homepage = "https://github.com/abdullahselek/HerePy";
    changelog = "https://github.com/abdullahselek/HerePy/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
