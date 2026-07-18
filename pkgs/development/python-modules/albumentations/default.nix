{
  lib,
  fetchFromGitHub,
  # dependencies
  albucore,
  buildPythonPackage,
  # tests
  deepdiff,
  # optional dependencies
  huggingface-hub,
  numpy,
  opencv-python,
  pillow,
  pydantic,
  pytest-mock,
  pytestCheckHook,
  pyyaml,
  scikit-image,
  scikit-learn,
  scipy,
  # build-system
  setuptools,
  torch,
  torchvision,
}:

buildPythonPackage rec {
  pname = "albumentations";
  version = "2.0.8";

  src = fetchFromGitHub {
    owner = "albumentations-team";
    repo = "albumentations";
    tag = version;
    hash = "sha256-8vUipdkIelRtKwMw63oUBDN/GUI0gegMGQaqDyXAOTQ=";
  };

  patches = [
    ./dont-check-for-updates.patch
  ];

  nativeCheckInputs = [
    deepdiff
    pytestCheckHook
    pytest-mock
    scikit-image
    scikit-learn
    torch
    torchvision
  ];

  build-system = [ setuptools ];

  dependencies = [
    albucore
    numpy
    opencv-python
    pydantic
    pyyaml
    scipy
  ];

  disabledTests = [
    "test_pca_inverse_transform"
    # these tests hang
    "test_keypoint_remap_methods"
    "test_multiprocessing_support"
  ];

  optional-dependencies = {
    hub = [ huggingface-hub ];
    pytorch = [ torch ];
    text = [ pillow ];
  };

  pyproject = true;
  pythonImportsCheck = [ "albumentations" ];
  pythonRelaxDeps = [ "opencv-python" ];

  meta = {
    description = "Fast image augmentation library and easy to use wrapper around other libraries";
    homepage = "https://github.com/albumentations-team/albumentations";
    changelog = "https://github.com/albumentations-team/albumentations/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ natsukium ];
  };
}
