{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # buildInputs
  libjpeg_turbo,
  # nativeBuildInputs
  libpng,
  ninja,
  # dependencies
  numpy,
  pillow,
  # tests
  pytest,
  scipy,
  torch,
  which,
  writableTmpDirAsHomeHook,
}:

let
  inherit (torch) cudaCapabilities cudaPackages cudaSupport;

in
buildPythonPackage.override { inherit (torch) stdenv; } (finalAttrs: {
  pname = "torchvision";
  version = "0.27.0";

  src = fetchFromGitHub {
    owner = "pytorch";
    repo = "vision";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HOTD45xY7Gye1GI1+AsF3KmMUTAp1QlzHOUeBHvzv0A=";
  };

  nativeBuildInputs = [
    libpng
    ninja
    which
  ]
  ++ lib.optionals cudaSupport [ cudaPackages.cuda_nvcc ];

  buildInputs = [
    libjpeg_turbo
    libpng
    torch.cxxdev
  ];

  env = {
    TORCHVISION_INCLUDE = "${libjpeg_turbo.dev}/include/";
    TORCHVISION_LIBRARY = "${libjpeg_turbo}/lib/";
  }
  // lib.optionalAttrs cudaSupport {
    FORCE_CUDA = 1;
    TORCH_CUDA_ARCH_LIST = "${lib.concatStringsSep ";" cudaCapabilities}";
  };

  # tests download big datasets, models, require internet connection, etc.
  doCheck = false;

  nativeCheckInputs = [
    pytest
    writableTmpDirAsHomeHook
  ];

  checkPhase = ''
    py.test test --ignore=test/test_datasets_download.py
  '';

  __structuredAttrs = true;

  dependencies = [
    numpy
    pillow
    torch
    scipy
  ];

  pyproject = true;
  pythonImportsCheck = [ "torchvision" ];

  meta = {
    description = "PyTorch vision library";
    homepage = "https://pytorch.org/vision";
    changelog = "https://github.com/pytorch/vision/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    platforms = with lib.platforms; linux ++ lib.optionals (!cudaSupport) darwin;
    downloadPage = "https://github.com/pytorch/vision";
  };
})
