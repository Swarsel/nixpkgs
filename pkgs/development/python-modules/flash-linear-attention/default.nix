{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # optional-dependencies
  causal-conv1d,
  datasets,
  # dependencies
  einops,
  matplotlib,
  pytest,
  pythonOlder,
  # build-system
  setuptools,
  torch,
  transformers,
}:

buildPythonPackage (finalAttrs: {
  pname = "flash-linear-attention";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "fla-org";
    repo = "flash-linear-attention";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vxNbZ+FkxJh2E0TF09Z7ghkm8eas7Q96heeSXwgV4uU=";
  };

  # Tests require a GPU
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    einops
    torch
    transformers
  ];

  disabled = pythonOlder "3.10";

  optional-dependencies = {
    benchmark = [
      matplotlib
      datasets
    ];

    # tilelang = [ tilelang ];
    conv1d = [ causal-conv1d ];
    test = [ pytest ];
  };

  pyproject = true;
  pythonImportsCheck = [ "fla" ];

  meta = {
    description = "Triton-based implementations of causal linear attention";
    homepage = "https://github.com/fla-org/flash-linear-attention";
    changelog = "https://github.com/fla-org/flash-linear-attention/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ BatteredBunny ];
  };
})
