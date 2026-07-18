{
  lib,
  buildPythonPackage,
  click,
  fetchPypi,
  h5py,
  numba,
  numpy,
  numpy-groupies,
  pytestCheckHook,
  scipy,
  setuptools,
}:
let
  finalAttrs = {
    pname = "loompy";
    version = "3.0.8";

    src = fetchPypi {
      inherit (finalAttrs) pname version;
      hash = "sha256-wfSNC/Iaorve7iGgV3VTy6lgnZQ118MraHaGu7WGnKc=";
    };

    nativeCheckInputs = [ pytestCheckHook ];
    build-system = [ setuptools ];

    dependencies = [
      h5py
      numpy
      scipy
      numba
      click
      numpy-groupies
    ];

    # Deprecated numpy attributes access
    disabledTests = [
      "test_scan_with_default_ordering"
      "test_get"
    ];

    pyproject = true;
    pythonImportsCheck = [ "loompy" ];

    meta = {
      description = "Python implementation of the Loom file format";
      homepage = "https://github.com/linnarsson-lab/loompy";
      changelog = "https://github.com/linnarsson-lab/loompy/releases";
      license = lib.licenses.bsd2;
      maintainers = with lib.maintainers; [ theobori ];
      mainProgram = "loompy";
    };
  };
in
buildPythonPackage finalAttrs
