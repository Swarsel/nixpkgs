{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  scipy,
  setuptools,
  torch,
  torchvision,
  tqdm,
}:

buildPythonPackage (finalAttrs: {
  pname = "lpips";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "richzhang";
    repo = "PerceptualSimilarity";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dIQ9B/HV/2kUnXLXNxAZKHmv/Xv37kl2n6+8IfwIALE=";
  };

  # Tests require network access to download pretrained models.
  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    numpy
    scipy
    torch
    torchvision
    tqdm
  ];

  pyproject = true;
  pythonImportsCheck = [ "lpips" ];

  meta = {
    description = "Learned Perceptual Image Patch Similarity metric";
    homepage = "https://github.com/richzhang/PerceptualSimilarity";
    changelog = "https://github.com/richzhang/PerceptualSimilarity/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ jeffcshelton ];
  };
})
