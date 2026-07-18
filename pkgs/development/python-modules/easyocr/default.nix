{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hdf5,
  numpy,
  opencv-python-headless,
  pillow,
  pyaml,
  pyclipper,
  python,
  python-bidi,
  scikit-image,
  scipy,
  setuptools,
  shapely,
  torch,
  torchvision,
}:

buildPythonPackage rec {
  pname = "easyocr";
  version = "1.7.2";

  src = fetchFromGitHub {
    owner = "JaidedAI";
    repo = "EasyOCR";
    tag = "v${version}";
    hash = "sha256-9mrAxt2lphYtLW81lGO5SYHsnMnSA/VpHiY2NffD/Js=";
  };

  # downloads detection model from the internet
  doCheck = false;

  checkPhase = ''
    runHook preCheck

    export HOME="$(mktemp -d)"
    pushd unit_test
    ${python.interpreter} run_unit_test.py --easyocr "$out/${python.sitePackages}/easyocr"
    popd

    runHook postCheck
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    hdf5
    numpy
    opencv-python-headless
    pillow
    pyaml
    pyclipper
    python-bidi
    scikit-image
    scipy
    shapely
    torch
    torchvision
  ];

  pyproject = true;
  pythonImportsCheck = [ "easyocr" ];

  pythonRelaxDeps = [
    "torchvision"
  ];

  pythonRemoveDeps = [
    "ninja"
  ];

  meta = {
    description = "Ready-to-use OCR with 80+ supported languages and all popular writing scripts";
    homepage = "https://github.com/JaidedAI/EasyOCR";
    changelog = "https://github.com/JaidedAI/EasyOCR/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "easyocr";
  };
}
