{
  lib,
  stdenv,
  fetchFromGitHub,
  boto3,
  buildPythonPackage,
  matplotlib,
  moto,
  numpy,
  packaging,
  protobuf,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  soundfile,
  tensorboard,
  torch,
  torchvision,
}:

buildPythonPackage rec {
  pname = "tensorboardx";
  version = "2.6.4";

  src = fetchFromGitHub {
    owner = "lanpa";
    repo = "tensorboardX";
    tag = "v${version}";
    hash = "sha256-GZQUJCiCKVthO95jHMIzNFcBM3R85BkyxO74CKCzizc=";
  };

  postPatch = ''
    # https://github.com/lanpa/tensorboardX/pull/761
    substituteInPlace tensorboardX/utils.py tests/test_utils.py \
      --replace-fail "newshape=" "shape="
  '';

  # required to make tests deterministic
  env.PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION = "python";

  nativeCheckInputs = [
    boto3
    matplotlib
    moto
    pytestCheckHook
    soundfile
    torch
    tensorboard
    torchvision
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    packaging
    protobuf
    numpy
  ];

  disabledTestPaths = [
    # we are not interested in linting errors
    "tests/test_lint.py"
    # ImportError: cannot import name 'mock_s3' from 'moto'
    "tests/test_embedding.py"
    "tests/test_record_writer.py"
  ];

  disabledTests = [
    # ImportError: Visdom visualization requires installation of Visdom
    "test_TorchVis"
    # Requires network access (FileNotFoundError: [Errno 2] No such file or directory: 'wget')
    "test_onnx_graph"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # Fails with a mysterious error in pytorch:
    # RuntimeError: required keyword attribute 'name' has the wrong type
    "test_pytorch_graph"
  ];

  pyproject = true;
  pythonImportsCheck = [ "tensorboardX" ];

  meta = {
    description = "Library for writing tensorboard-compatible logs";
    homepage = "https://tensorboardx.readthedocs.io";
    changelog = "https://github.com/lanpa/tensorboardX/blob/${src.tag}/HISTORY.rst";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      lebastr
      akamaus
    ];

    platforms = lib.platforms.all;
    downloadPage = "https://github.com/lanpa/tensorboardX";
  };
}
