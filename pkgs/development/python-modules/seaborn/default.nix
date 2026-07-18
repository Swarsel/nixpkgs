{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch2,
  flit-core,
  matplotlib,
  numpy,
  pandas,
  pytest-xdist,
  pytest8_3CheckHook,
  scipy,
  statsmodels,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "seaborn";
  version = "0.13.2";

  src = fetchFromGitHub {
    owner = "mwaskom";
    repo = "seaborn";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aGIVcdG/XN999nYBHh3lJqGa3QVt0j8kmzaxdkULznY=";
  };

  patches = [
    # https://github.com/mwaskom/seaborn/pull/3685
    (fetchpatch2 {
      hash = "sha256-/a3G+kNIRv8Oa4a0jPGnL2Wvx/9umMoiq1BXcXpehAg=";
      name = "numpy_2-compatibility.patch";
      url = "https://github.com/mwaskom/seaborn/commit/58f170fe799ef496adae19925d7d4f0f14f8da95.patch";
    })
    # https://github.com/mwaskom/seaborn/pull/3802
    (fetchpatch2 {
      hash = "sha256-nwGwTkP7W9QzgbbAVdb2rASgsMxqFnylMk8GnTE445w=";
      name = "matplotlib_3_10-compatibility.patch";
      url = "https://github.com/mwaskom/seaborn/commit/385e54676ca16d0132434bc9df6bc41ea8b2a0d4.patch";
    })
    (fetchpatch2 {
      hash = "sha256-T3OfjEEsPRRv1J6gdq9XmwcWEpPMDzul+LmK8UtV7nk=";
      name = "numpy-2.4-compat.patch";
      url = "https://github.com/mwaskom/seaborn/commit/5023f2ee885a45200f5b63156a158ddf7272c29e.patch";
    })
  ];

  # All platforms should use Agg. Let's set it explicitly to avoid probing GUI
  # backends (leads to crashes on macOS).
  env.MPLBACKEND = "Agg";

  nativeCheckInputs = [
    pytest-xdist
    pytest8_3CheckHook
    writableTmpDirAsHomeHook
  ];

  __structuredAttrs = true;
  build-system = [ flit-core ];

  dependencies = [
    matplotlib
    numpy
    pandas
  ];

  disabledTests = [
    # requires internet connection
    "test_load_dataset_string_error"
    # matplotlib error string matching
    "test_theme_validation"
    # log scale transformation match too strict
    "test_log_scale"
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isx86) [
    # overly strict float tolerances
    "TestDendrogram"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # overly strict float tolerances
    "test_ticklabels_overlap"
  ];

  optional-dependencies = {
    stats = [
      scipy
      statsmodels
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "seaborn" ];

  meta = {
    description = "Statistical data visualization";
    homepage = "https://seaborn.pydata.org/";
    changelog = "https://github.com/mwaskom/seaborn/blob/${finalAttrs.src.tag}/doc/whatsnew/${finalAttrs.src.tag}.rst";
    license = with lib.licenses; [ bsd3 ];
    maintainers = with lib.maintainers; [ miniharinn ];
  };
})
