{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colorlog,
  dataclasses-json,
  fetchpatch,
  nltk,
  numpy,
  pandas,
  poetry-core,
  psutil,
  py3langid,
  pytestCheckHook,
  python-dateutil,
  scipy,
  standard-imghdr,
  standard-sndhdr,
  toml,
}:
let
  testNltkData = nltk.dataDir (d: [
    d.punkt
    d.punkt-tab
    d.stopwords
  ]);

  version = "0.0.26";
  tag = "v${version}";
in
buildPythonPackage {
  inherit version;
  pname = "type-infer";

  src = fetchFromGitHub {
    inherit tag;
    owner = "mindsdb";
    repo = "type_infer";
    hash = "sha256-6zfe9C/werr2CbF//UuzuvP2fpwOVRy4VIlGE8UgY0o=";
  };

  patches = [
    # https://github.com/mindsdb/type_infer/pull/83
    (fetchpatch {
      hash = "sha256-wNBzb+RxoZC8zn5gdOrtJeXJIIH3DTt1gTZfgN/WnQQ=";
      url = "https://github.com/mindsdb/type_infer/commit/d09f88d5ddbe55125b1fff4506b03165d019d88b.patch";
    })
  ];

  # Package import requires NLTK data to be downloaded
  # It is the only way to set NLTK_DATA environment variable,
  # so that it is available in pythonImportsCheck
  env.NLTK_DATA = testNltkData;

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    colorlog
    dataclasses-json
    nltk
    numpy
    pandas
    psutil
    py3langid
    python-dateutil
    scipy
    standard-imghdr
    standard-sndhdr
    toml
  ];

  disabledTests = [
    # test hangs
    "test_1_stack_overflow_survey"
  ];

  pyproject = true;
  pythonImportsCheck = [ "type_infer" ];

  pythonRelaxDeps = [
    "psutil"
    "py3langid"
    "numpy"
  ];

  meta = {
    description = "Automated type inference for Machine Learning pipelines";
    homepage = "https://github.com/mindsdb/type_infer";
    changelog = "https://github.com/mindsdb/type_infer/releases/tag/${tag}";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
  };
}
