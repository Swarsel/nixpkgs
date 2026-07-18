{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  torch,
}:

buildPythonPackage rec {
  pname = "ttach";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "qubvel";
    repo = "ttach";
    tag = "v${version}";
    hash = "sha256-R6QO+9hv0eI7dZW5iJf096+LU1q+vnmOpveurgZemPc=";
  };

  propagatedBuildInputs = [ torch ];
  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "ttach" ];

  meta = {
    description = "Image Test Time Augmentation with PyTorch";
    homepage = "https://github.com/qubvel/ttach";
    license = with lib.licenses; [ mit ];
  };
}
