{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  codecarbon,
  colorama,
  matplotlib,
  # passthru
  nix-update-script,
  numpy,
  nvidia-ml-py,
  # build-system
  setuptools,
  torch,
  torchprofile,
  tqdm,
}:

buildPythonPackage {
  pname = "pytorch-bench";
  version = "0-unstable-2025-05-05";

  src = fetchFromGitHub {
    owner = "MaximeGloesener";
    repo = "torch-benchmark";
    rev = "f22db3b2e5920cf084e088e7748e3ffd32343853";
    hash = "sha256-+jd+H5hL+DotlLaBiaixb//hxyvEF6aAJYSHX1hfsP8=";
  };

  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    codecarbon
    colorama
    matplotlib
    numpy
    nvidia-ml-py
    torch
    torchprofile
    tqdm
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytorch_bench" ];

  pythonRemoveDeps = [
    # pynvml is deprecated and replaced by nvidia-ml-py which provides the same API
    "pynvml"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    description = "Benchmarking tool for torch";
    homepage = "https://github.com/MaximeGloesener/torch-benchmark";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
