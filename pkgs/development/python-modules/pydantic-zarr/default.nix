{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  dask,
  # build-system
  hatch-vcs,
  hatchling,
  # dependencies
  numpy,
  packaging,
  pydantic,
  pytest-examples,
  pytestCheckHook,
  xarray,
}:

buildPythonPackage (finalAttrs: {
  pname = "pydantic-zarr";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "zarr-developers";
    repo = "pydantic-zarr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SzvYiZWnknGdJexYnGEWQaVQpHo1520RaNjuzCA4xtQ=";
  };

  nativeCheckInputs = [
    dask
    pytest-examples
    pytestCheckHook
    xarray
  ];

  __structuredAttrs = true;

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    numpy
    packaging
    pydantic
  ];

  pyproject = true;
  pythonImportsCheck = [ "pydantic_zarr" ];

  meta = {
    description = "Pydantic models for Zarr";
    homepage = "https://github.com/zarr-developers/pydantic-zarr";
    changelog = "https://github.com/zarr-developers/pydantic-zarr/releases/tag/${finalAttrs.src.tag}";

    license = with lib.licenses; [
      bsd3
      mit
    ];

    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
