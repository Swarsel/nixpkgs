{
  lib,
  buildPythonPackage,
  fetchPypi,
  matplotlib,
  numpy,
  opencv-python,
  pillow,
  scikit-learn,
  setuptools,
  torch,
  torchvision,
  tqdm,
  ttach,
}:

buildPythonPackage rec {
  pname = "grad-cam";
  version = "1.5.5";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-aQxDPSJtNcicnrFwRi2yBJCcsGs5xzgeaICkm2/DcBU=";
  };

  nativeBuildInputs = [
  ];

  # Let the user bring their own instance (as with torchmetrics)
  buildInputs = [ torch ];
  doCheck = false; # every nontrivial test tries to download a pretrained model

  build-system = [
    setuptools
  ];

  dependencies = [
    matplotlib
    numpy
    opencv-python
    pillow
    scikit-learn
    torchvision
    ttach
    tqdm
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pytorch_grad_cam"
    "pytorch_grad_cam.metrics"
    "pytorch_grad_cam.metrics.cam_mult_image"
    "pytorch_grad_cam.metrics.road"
    "pytorch_grad_cam.utils"
    "pytorch_grad_cam.utils.image"
    "pytorch_grad_cam.utils.model_targets"
  ];

  pythonRelaxDeps = [
    "torchvision"
  ];

  meta = {
    description = "Advanced AI explainability for computer vision";
    homepage = "https://jacobgil.github.io/pytorch-gradcam-book";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
