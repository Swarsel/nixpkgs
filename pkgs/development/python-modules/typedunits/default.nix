{
  lib,
  stdenv,
  fetchFromGitHub,
  attrs,
  buildPythonPackage,
  cython,
  numpy,
  protobuf,
  pyparsing,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "typedunits";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "quantumlib";
    repo = "TypedUnits";
    tag = "v${version}";
    hash = "sha256-dADN9zBwspfDPdgce5EKEclI1qLcqc0N09RGsiPrJ0c=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    cython
    setuptools
  ];

  dependencies = [
    attrs
    cython
    numpy
    protobuf
    pyparsing
  ];

  disabledTestPaths = [
    # Flaky due to host timing differences under load
    "test_perf/test_array_with_dimension_performance.py"
    "test_perf/test_value_array_performance.py"
    "test_perf/test_value_performance.py"
    "test_perf/test_value_with_dimension_performance.py"
  ];

  disabledTests = lib.optionals stdenv.hostPlatform.isAarch [
    # Rounding differences
    "test_float_to_twelths_frac"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "tunits"
  ];

  meta = {
    description = "Units and dimensions library with support for static dimensionality checking and protobuffer serialization";
    homepage = "https://github.com/quantumlib/TypedUnits";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ sarahec ];
  };
}
