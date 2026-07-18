{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  datasets,
  einops,
  # tests
  expecttest,
  fsspec,
  pillow,
  pytestCheckHook,
  # build-system
  setuptools,
  tensorboard,
  tokenizers,
  tomli,
  tomli-w,
  torch,
  torchdata,
  transformers,
  triton,
  tyro,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "torchtitan";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "pytorch";
    repo = "torchtitan";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YXbbqNjmPBIFDRbvagHRIy5ph1pZmSerUxlqaF6f4cY=";
  };

  nativeCheckInputs = [
    expecttest
    pytestCheckHook
    tomli-w
    transformers
    triton
    writableTmpDirAsHomeHook
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    datasets
    einops
    fsspec
    pillow
    tensorboard
    tokenizers
    tomli
    torch
    torchdata
    tyro
  ];

  disabledTestPaths = [
    # Require internet access
    "tests/unit_tests/test_tokenizer.py"
  ];

  disabledTests = [
    # Require internet access
    "test_list_files"
  ];

  pyproject = true;
  pythonImportsCheck = [ "torchtitan" ];

  meta = {
    description = "PyTorch native platform for training generative AI models";
    homepage = "https://github.com/pytorch/torchtitan";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
