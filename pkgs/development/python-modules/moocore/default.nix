{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cffi,
  # dependencies
  numpy,
  platformdirs,
  # tests
  pytestCheckHook,
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "moocore";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "multi-objective";
    repo = "moocore";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6KWDnL/efGg8ss4eARQptoTYxxdLYjeg0DgDyEpxZT8=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  __structuredAttrs = true;

  build-system = [
    cffi
    setuptools
  ];

  dependencies = [
    cffi
    numpy
    platformdirs
  ];

  disabledTests = [
    # Require downloading data from the internet
    "test_read_datasets_data"
  ];

  pyproject = true;
  pythonImportsCheck = [ "moocore" ];
  sourceRoot = "${finalAttrs.src.name}/python";

  meta = {
    description = "Core Mathematical Functions for Multi-Objective Optimization";
    homepage = "https://github.com/multi-objective/moocore/tree/main/python";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
