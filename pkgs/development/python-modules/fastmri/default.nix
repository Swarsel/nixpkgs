{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  h5py,
  # dependencies
  numpy,
  pandas,
  # tests
  pytestCheckHook,
  pythonAtLeast,
  pytorch-lightning,
  pyyaml,
  requests,
  runstats,
  scikit-image,
  # build system
  setuptools,
  setuptools-scm,
  torch,
  torchmetrics,
  torchvision,
}:

buildPythonPackage (finalAttrs: {
  pname = "fastmri";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "facebookresearch";
    repo = "fastMRI";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0IJV8OhY5kPWQwUYPKfmdI67TyYzDAPlwohdc0jWcV4=";
  };

  # banding_removal folder also has a subfolder named "fastmri"
  # and np.product is substituted with np.prod in new numpy versions
  postPatch = ''
    substituteInPlace tests/test_math.py \
      --replace-fail "np.product" "np.prod"
    substituteInPlace tests/conftest.py \
      --replace-fail "np.product" "np.prod"

    rm -rf banding_removal
  '';

  nativeCheckInputs = [
    pytestCheckHook
    requests
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    numpy
    scikit-image
    torchvision
    torch
    runstats
    pytorch-lightning
    h5py
    pyyaml
    torchmetrics
    pandas
  ];

  disabledTestPaths = [
    # much older version of pytorch-lightning is used
    "tests/test_modules.py"
  ];

  disabledTests = lib.optionals (pythonAtLeast "3.14") [
    # AttributeError: '...' object has no attribute '__annotations__'.
    "test_unet_scripting"
    "test_varnet_scripting"
  ];

  pyproject = true;
  pythonImportsCheck = [ "fastmri" ];

  meta = {
    description = "Pytorch-based MRI reconstruction tooling";
    homepage = "https://github.com/facebookresearch/fastMRI";
    changelog = "https://github.com/facebookresearch/fastMRI/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ osbm ];
  };
})
