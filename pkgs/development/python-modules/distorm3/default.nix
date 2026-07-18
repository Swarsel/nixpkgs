{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  distutils,
  pytestCheckHook,
  setuptools,
  yasm,
}:

buildPythonPackage rec {
  pname = "distorm3";
  version = "3.5.2";

  src = fetchFromGitHub {
    owner = "gdabah";
    repo = "distorm";
    tag = version;
    hash = "sha256-Fhvxag2UN5wXEySP1n1pCahMQR/SfssywikeLmiASwQ=";
  };

  # TypeError: __init__() missing 3 required positional...
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    yasm
  ];

  build-system = [
    distutils
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "distorm3" ];

  meta = {
    description = "Disassembler library for x86/AMD64";
    homepage = "https://github.com/gdabah/distorm";
    changelog = "https://github.com/gdabah/distorm/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
  };
}
