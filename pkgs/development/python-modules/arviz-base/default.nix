{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  flit-core,
  # optional-dependencies
  h5netcdf,
  # dependencies
  lazy-loader,
  netcdf4,
  numpy,
  # tests
  pytestCheckHook,
  typing-extensions,
  writableTmpDirAsHomeHook,
  xarray,
  zarr,
}:

buildPythonPackage (finalAttrs: {
  pname = "arviz-base";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "arviz-devs";
    repo = "arviz-base";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IMS5t+ezAoALBxk0PnX7G+DFNfYW20Qd+/M2p1IzktA=";
  };

  nativeCheckInputs = [
    h5netcdf
    netcdf4
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  __structuredAttrs = true;

  build-system = [
    flit-core
  ];

  dependencies = [
    lazy-loader
    numpy
    typing-extensions
    xarray
  ];

  optional-dependencies = {
    h5netcdf = [
      h5netcdf
    ];

    netcdf4 = [
      netcdf4
    ];

    zarr = [
      zarr
    ];
  };

  pyproject = true;

  pytestFlags = [
    # DeprecationWarning: Setting the shape on a NumPy array has been deprecated in NumPy 2.5.
    "-Wignore::DeprecationWarning"
  ];

  pythonImportsCheck = [ "arviz_base" ];

  meta = {
    description = "Base ArviZ features and converters";
    homepage = "https://github.com/arviz-devs/arviz-base";
    changelog = "https://github.com/arviz-devs/arviz-base/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
