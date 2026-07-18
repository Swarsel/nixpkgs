{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pillow,
  pywavelets,
  scipy,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyssim";
  version = "0.7.1";

  # PyPI tarball doesn't contain test images so let's use GitHub
  src = fetchFromGitHub {
    owner = "jterrace";
    repo = "pyssim";
    tag = "v${version}";
    hash = "sha256-6393EATaXg12pYXPaHty+8LepUM6kgtZ0zSjZ1Izytg=";
  };

  # Tests are copied from .github/workflows/python-package.yml
  checkPhase = ''
    runHook preCheck
    $out/bin/pyssim test-images/test1-1.png test-images/test1-1.png | grep 1
    $out/bin/pyssim test-images/test1-1.png test-images/test1-2.png | grep 0.998
    $out/bin/pyssim test-images/test1-1.png "test-images/*" | grep -E " 1| 0.998| 0.672| 0.648" | wc -l | grep 4
    $out/bin/pyssim --cw --width 128 --height 128 test-images/test1-1.png test-images/test1-1.png | grep 1
    $out/bin/pyssim --cw --width 128 --height 128 test-images/test3-orig.jpg test-images/test3-rot.jpg | grep 0.938
    runHook postCheck
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    numpy
    scipy
    pillow
    pywavelets
  ];

  pyproject = true;

  meta = {
    description = "Module for computing Structured Similarity Image Metric (SSIM) in Python";
    homepage = "https://github.com/jterrace/pyssim";
    changelog = "https://github.com/jterrace/pyssim/blob/${src.tag}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jluttine ];
    mainProgram = "pyssim";
  };
}
