{
  lib,
  buildPythonPackage,
  fetchPypi,
  omegaconf,
  pycocotools,
  timm,
  # build inputs
  torch,
  torchvision,
}:
let
  pname = "effdet";
  version = "0.4.1";
in
buildPythonPackage {
  inherit pname version;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-rFWJ/TBKVlDCAZhrLvX44QwREJOnGxxJ+muIF3EIErU=";
  };

  propagatedBuildInputs = [
    torch
    torchvision
    timm
    pycocotools
    omegaconf
  ];

  # Project has no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "effdet" ];

  meta = {
    description = "PyTorch implementation of EfficientDet";
    homepage = "https://pypi.org/project/effdet";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ happysalada ];
  };
}
