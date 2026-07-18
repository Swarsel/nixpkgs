{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "inference-gym";
  version = "0.0.5";

  src = fetchPypi {
    inherit format version;
    hash = "sha256-E3lNgCZIObPBkl0PWACUG19XOiCOh1+N/sUFHQyA/wE=";
    dist = "py3";
    pname = "inference_gym";
    python = "py3";
  };

  # The package does not ship any test.
  doCheck = false;
  format = "wheel";
  pythonImportsCheck = [ "inference_gym" ];

  meta = {
    description = "Place to exercise inference methods to help make them faster, leaner and more robust";
    homepage = "https://github.com/tensorflow/probability/tree/main/spinoffs/inference_gym";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
