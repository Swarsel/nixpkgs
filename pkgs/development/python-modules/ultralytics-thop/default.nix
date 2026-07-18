{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  numpy,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
  torch,
}:

buildPythonPackage rec {
  pname = "ultralytics-thop";
  version = "2.0.19";

  src = fetchFromGitHub {
    owner = "ultralytics";
    repo = "thop";
    tag = "v${version}";
    hash = "sha256-icBfJagsK2DabMC8xgWNT1o3EdDGL+U2UyIf/LfugYc=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    numpy
    torch
  ];

  pyproject = true;
  pythonImportsCheck = [ "thop" ];

  meta = {
    description = "Profile PyTorch models by computing the number of Multiply-Accumulate Operations (MACs) and parameters";
    homepage = "https://github.com/ultralytics/thop";
    changelog = "https://github.com/ultralytics/thop/releases/tag/${src.tag}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ osbm ];
  };
}
