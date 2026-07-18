{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  pillow,
  requests,
  # build-system
  setuptools,
  torchvision,
}:

buildPythonPackage (finalAttrs: {
  pname = "facenet-pytorch";
  version = "2.5.3";

  src = fetchFromGitHub {
    owner = "timesler";
    repo = "facenet-pytorch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3YVyqKgVLD5aePwyVQA8kOiqx32kqg9lxU2uwPWGkCU=";
  };

  # The only tests require internet access
  doCheck = false;
  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    pillow
    requests
    torchvision
  ];

  pyproject = true;
  pythonImportsCheck = [ "facenet_pytorch" ];

  meta = {
    description = "Pretrained Pytorch face detection (MTCNN) and facial recognition (InceptionResnet) models";
    homepage = "https://github.com/timesler/facenet-pytorch";
    changelog = "https://github.com/timesler/facenet-pytorch/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
