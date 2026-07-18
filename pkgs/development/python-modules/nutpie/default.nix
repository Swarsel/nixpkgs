{
  lib,
  stdenv,
  fetchFromGitHub,
  # dependencies
  arro3-core,
  arviz,
  buildPythonPackage,
  # build-system
  cargo,
  # tests
  # bridgestan, (not packaged)
  equinox,
  flowjax,
  jax,
  jaxlib,
  numba,
  obstore,
  pandas,
  platformdirs,
  pyarrow,
  pymc,
  pytest-timeout,
  pytestCheckHook,
  rustPlatform,
  rustc,
  setuptools,
  writableTmpDirAsHomeHook,
  xarray,
  zarr,
}:

buildPythonPackage (finalAttrs: {
  pname = "nutpie";
  version = "0.16.11";

  src = fetchFromGitHub {
    owner = "pymc-devs";
    repo = "nutpie";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZakNyVW06QONdBSZFonOc585ZPLHsIjbFlBnX+Kg2kc=";
  };

  nativeCheckInputs = [
    # bridgestan
    equinox
    flowjax
    numba
    jax
    jaxlib
    platformdirs
    pymc
    pytest-timeout
    pytestCheckHook
    setuptools
    writableTmpDirAsHomeHook
  ];

  __structuredAttrs = true;

  build-system = [
    cargo
    rustPlatform.bindgenHook
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    rustc
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-n61ZrJtJFQ0G/7X59pKI8QNnOZPvDWiPmGC3tW3NQkk=";
  };

  dependencies = [
    arro3-core
    arviz
    obstore
    pandas
    pyarrow
    xarray
    zarr
  ];

  disabledTestPaths = [
    # Require unpackaged bridgestan
    "tests/test_stan.py"
  ];

  disabledTests = lib.optionals (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64) [
    # flaky (assert np.float64(0.0017554642626285276) > 0.01)
    "test_normalizing_flow"
  ];

  pyproject = true;
  pythonImportsCheck = [ "nutpie" ];

  meta = {
    description = "Python wrapper for nuts-rs";
    homepage = "https://github.com/pymc-devs/nutpie";
    changelog = "https://github.com/pymc-devs/nutpie/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
