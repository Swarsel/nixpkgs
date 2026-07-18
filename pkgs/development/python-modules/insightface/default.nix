{
  lib,
  stdenv,
  albumentations,
  buildPythonPackage,
  cython,
  fetchPypi,
  insightface,
  matplotlib,
  mxnet,
  numpy,
  onnx,
  onnxruntime,
  opencv-python,
  pillow,
  pyside6,
  reportlab,
  requests,
  scikit-image,
  scikit-learn,
  scipy,
  setuptools,
  testers,
  tqdm,
}:

buildPythonPackage rec {
  pname = "insightface";
  version = "1.0.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-J68kiRu7pHDLNXOzZqD8yomJ/IUDyfjygejLpv1xYHU=";
  };

  doCheck = false; # Upstream has no tests

  build-system = [
    cython
    setuptools
  ];

  dependencies = [
    mxnet # used in insightface/commands/rec_add_mask_param.py
    numpy
    onnx
    onnxruntime
    opencv-python
    requests
    scikit-image
    scipy
    tqdm
  ];

  # aarch64-linux tries to get cpu information from /sys, which isn't available
  # inside the nix build sandbox.
  dontUsePythonImportsCheck = stdenv.buildPlatform.system == "aarch64-linux";

  optional-dependencies = {
    face3d = [
      albumentations
      matplotlib
    ];

    gui = [
      pillow
      pyside6
      reportlab
      scikit-learn
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "insightface"
    "insightface.app"
    "insightface.data"
  ];

  passthru.tests = lib.optionalAttrs (stdenv.buildPlatform.system != "aarch64-linux") {
    version = testers.testVersion {
      # Doesn't support --version but we still want to make sure the cli is executable
      # and returns the help output
      version = "help";
      command = "insightface-cli --help";
      package = insightface;
    };
  };

  meta = {
    description = "State-of-the-art 2D and 3D Face Analysis Project";
    homepage = "https://github.com/deepinsight/insightface";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ oddlama ];
    mainProgram = "insightface-cli";
  };
}
