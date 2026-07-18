{
  lib,
  stdenv,
  fetchFromGitHub,
  # buildInputs
  boost,
  buildPythonPackage,
  cloudpickle,
  # nativeBuildInputs
  cmake,
  hypothesis,
  nanobind,
  ninja,
  # dependencies
  numpy,
  # build-system
  pybind11,
  pytest-benchmark,
  pytest-xdist,
  # tests
  pytestCheckHook,
  scikit-build-core,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "boost-histogram";
  version = "1.7.2";

  src = fetchFromGitHub {
    owner = "scikit-hep";
    repo = "boost-histogram";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nDNSLpmQ3YOo/nEkHfvsE0l9yATzQnrlunX1qWupbLQ=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ boost ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-benchmark
    pytest-xdist
    cloudpickle
    hypothesis
  ];

  __structuredAttrs = true;

  build-system = [
    pybind11
    nanobind
    ninja
    scikit-build-core
    setuptools-scm
  ];

  dependencies = [ numpy ];

  disabledTests =
    lib.optionals stdenv.hostPlatform.isDarwin [
      # Trace/BPT trap: 5
      "test_round_trip_3d_histogram_json"
    ]
    ++ lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
      # Segfaults: boost_histogram/_internal/hist.py", line 799 in sum
      # Fatal Python error: Segmentation fault
      "test_numpy_conversion_4"
    ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pytestFlags = [ "--benchmark-disable" ];
  pythonImportsCheck = [ "boost_histogram" ];

  meta = {
    description = "Python bindings for the C++14 Boost::Histogram library";
    homepage = "https://github.com/scikit-hep/boost-histogram";
    changelog = "https://github.com/scikit-hep/boost-histogram/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ veprbl ];
  };
})
