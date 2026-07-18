{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  hatchling,
  # tests
  jupyter,
  nbconvert,
  numpy,
  parameterized,
  pillow,
  pytestCheckHook,
  torch,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "einops";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "arogozhnikov";
    repo = "einops";
    tag = "v${finalAttrs.version}";
    hash = "sha256-d5Vbtkw/MChS2j2IC6j97wfVoKWZT9mU4OeXyEjm6ys=";
  };

  env.EINOPS_TEST_BACKENDS = "numpy";

  nativeCheckInputs = [
    jupyter
    nbconvert
    numpy
    parameterized
    pillow
    pytestCheckHook
    torch
    writableTmpDirAsHomeHook
  ];

  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;
  build-system = [ hatchling ];

  disabledTestPaths = [
    # skip folder with notebook samples that depend on large packages
    # or accelerator access and have been unreliable
    "scripts/"
  ];

  pyproject = true;
  pythonImportsCheck = [ "einops" ];

  meta = {
    description = "Flexible and powerful tensor operations for readable and reliable code";
    homepage = "https://github.com/arogozhnikov/einops";
    changelog = "https://github.com/arogozhnikov/einops/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ yl3dy ];
  };
})
