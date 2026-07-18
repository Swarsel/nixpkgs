{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  torch,
  wheel,
}:

buildPythonPackage rec {
  pname = "pytorch-msssim";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "VainF";
    repo = "pytorch-msssim";
    tag = "v${version}";
    hash = "sha256-bghglwQhgByC7BqbDvImSvt6edKF55NLYEPjqmmSFH8=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [ torch ];
  # This test doesn't have (automatic) tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "pytorch_msssim" ];

  meta = {
    description = "Fast and differentiable MS-SSIM and SSIM for pytorch";
    homepage = "https://github.com/VainF/pytorch-msssim";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
