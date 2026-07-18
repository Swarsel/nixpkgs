{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  rustPlatform,
}:

buildPythonPackage rec {
  pname = "test-results-parser";
  version = "0.6.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Xqktx66EvYnpw/w3UxfYXJgfnROcPMobCv4W2W405/Y=";
    pname = "test_results_parser";
  };

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-xnX9YwRHo5vFcF4HDj9K/hLV88ZB0UZdpx8RdA+EmrU=";
  };

  pyproject = true;

  pythonImportsCheck = [
    "test_results_parser"
  ];

  meta = {
    description = "Codecov test results parser";
    homepage = "https://github.com/codecov/test-results-parser";
    license = lib.licenses.fsl11Asl20;
    maintainers = with lib.maintainers; [ veehaitch ];
  };
}
