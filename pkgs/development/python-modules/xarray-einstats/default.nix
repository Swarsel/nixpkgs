{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  einops,
  flit-core,
  numba,
  numpy,
  pytestCheckHook,
  scipy,
  xarray,
}:

buildPythonPackage (finalAttrs: {
  pname = "xarray-einstats";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "arviz-devs";
    repo = "xarray-einstats";
    tag = "v${finalAttrs.version}";
    hash = "sha256-R/CbCaToW9U0+WqayE33gSyx5wKrhlZd7w4kjyxoxrk=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ lib.flatten (builtins.attrValues finalAttrs.passthru.optional-dependencies);

  build-system = [ flit-core ];

  dependencies = [
    numpy
    scipy
    xarray
  ];

  disabledTests = [
    # TypeError
    "test_pinv"
  ];

  optional-dependencies = {
    einops = [ einops ];
    numba = [ numba ];
  };

  pyproject = true;
  pythonImportsCheck = [ "xarray_einstats" ];

  meta = {
    description = "Stats, linear algebra and einops for xarray";
    homepage = "https://github.com/arviz-devs/xarray-einstats";
    changelog = "https://github.com/arviz-devs/xarray-einstats/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
