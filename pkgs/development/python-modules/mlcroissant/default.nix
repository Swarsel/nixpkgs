{
  lib,
  fetchFromGitHub,
  # dependencies
  absl-py,
  # tests
  apache-beam,
  buildPythonPackage,
  etils,
  gitpython,
  jsonpath-rw,
  librosa,
  networkx,
  pandas,
  pandas-stubs,
  pillow,
  pytestCheckHook,
  python-dateutil,
  pyyaml,
  rdflib,
  requests,
  scipy,
  # build-system
  setuptools,
  tqdm,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "mlcroissant";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "mlcommons";
    repo = "croissant";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IaRlmNQjOSIT3/b6AM68eRmweZEI5yjo6I9ievQIIsE=";
  };

  nativeCheckInputs = [
    apache-beam
    gitpython
    librosa
    pillow
    pytestCheckHook
    pyyaml
    writableTmpDirAsHomeHook
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    absl-py
    etils
    jsonpath-rw
    networkx
    pandas
    pandas-stubs
    python-dateutil
    rdflib
    requests
    scipy
    tqdm
  ]
  ++ etils.optional-dependencies.epath;

  disabledTests = [
    # Requires internet access
    "test_hermetic_loading_1_1"
    "test_load_from_huggingface"
    "test_nonhermetic_loading"
    "test_nonhermetic_loading_1_0"

    # AssertionError: assert {'records/aud...t32), 22050)'} == {'records/aud...t32), 22050)'}
    "test_hermetic_loading"

    # AttributeError: 'MaybeReshuffle' object has no attribute 'side_inputs'
    "test_beam_hermetic_loading"
  ];

  pyproject = true;
  pythonImportsCheck = [ "mlcroissant" ];
  sourceRoot = "${finalAttrs.src.name}/python/mlcroissant";

  meta = {
    description = "High-level format for machine learning datasets that brings together four rich layers";
    homepage = "https://github.com/mlcommons/croissant";
    changelog = "https://github.com/mlcommons/croissant/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    platforms = lib.platforms.all;
    mainProgram = "mlcroissant";
  };
})
