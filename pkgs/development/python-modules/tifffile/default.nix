{
  lib,
  buildPythonPackage,
  dask,
  fetchPypi,
  fsspec,
  lxml,
  numpy,
  pytestCheckHook,
  setuptools,
  zarr,
}:

buildPythonPackage rec {
  pname = "tifffile";
  version = "2026.1.14";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-pCPFg+HuzZyiVWQtR/Rj76jX8jZaDhEOsBZ1cEk+DIw=";
  };

  # flaky, often killed due to OOM or timeout
  env.SKIP_LARGE = "1";

  nativeCheckInputs = [
    dask
    fsspec
    lxml
    pytestCheckHook
    zarr
  ];

  build-system = [ setuptools ];
  dependencies = [ numpy ];

  disabledTests = [
    # Test require network access
    "test_class_omexml"
    "test_write_ome"
    # Test file is missing
    "test_write_predictor"
    "test_issue_imagej_hyperstack_arg"
    "test_issue_description_overwrite"
    # AssertionError
    "test_write_bigtiff"
    "test_write_imagej_raw"
    # https://github.com/cgohlke/tifffile/issues/142
    "test_func_bitorder_decode"
    # Test file is missing
    "test_issue_invalid_predictor"
  ];

  pyproject = true;
  pythonImportsCheck = [ "tifffile" ];

  meta = {
    description = "Read and write image data from and to TIFF files";
    homepage = "https://github.com/cgohlke/tifffile/";
    changelog = "https://github.com/cgohlke/tifffile/blob/v${version}/CHANGES.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ lebastr ];
  };
}
