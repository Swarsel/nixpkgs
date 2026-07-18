{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  hatchling,
  # tests
  numpy,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "wadler-lindig";
  version = "0.1.7";

  src = fetchFromGitHub {
    owner = "patrick-kidger";
    repo = "wadler_lindig";
    tag = "v${version}";
    hash = "sha256-qP826zdzR5BEQ8bGd45RFSLTH6Eal+b7UN+BW07/glo=";
  };

  nativeCheckInputs = [
    numpy
    pytestCheckHook
  ];

  build-system = [
    hatchling
  ];

  pyproject = true;

  pythonImportsCheck = [
    "wadler_lindig"
  ];

  meta = {
    description = "Wadler--Lindig pretty printer for Python";
    homepage = "https://github.com/patrick-kidger/wadler_lindig";
    changelog = "https://github.com/patrick-kidger/wadler_lindig/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
