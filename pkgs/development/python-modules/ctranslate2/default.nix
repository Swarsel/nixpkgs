{
  lib,
  stdenv,
  buildPythonPackage,
  # dependencies
  ctranslate2-cpp,
  numpy,
  # build-system
  pybind11,
  # tests
  pytestCheckHook,
  pyyaml,
  setuptools,
  torch,
  transformers,
  writableTmpDirAsHomeHook,
  wurlitzer,
}:

buildPythonPackage rec {
  inherit (ctranslate2-cpp) pname version src;

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "pybind11==" "pybind11>="
  '';

  buildInputs = [ ctranslate2-cpp ];
  cmakeFlags = [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];

  nativeCheckInputs = [
    pytestCheckHook
    torch
    transformers
    writableTmpDirAsHomeHook
    wurlitzer
  ];

  preCheck = ''
    # run tests against build result, not sources
    rm -rf ctranslate2
  '';

  build-system = [
    pybind11
    setuptools
  ];

  dependencies = [
    numpy
    pyyaml
  ];

  disabledTestPaths = [
    # TODO: ModuleNotFoundError: No module named 'opennmt'
    "tests/test_opennmt_tf.py"
    # OSError: We couldn't connect to 'https://huggingface.co' to load this file
    "tests/test_transformers.py"
  ];

  disabledTests =
    lib.optionals (stdenv.hostPlatform.isAarch64 && stdenv.hostPlatform.isLinux) [
      # RuntimeError: Failed to initialize cpuinfo!"
      "test_torch_variables"
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      # Fatal Python error: Aborted
      "test_invalid_model_path"
    ];

  pyproject = true;

  pythonImportsCheck = [
    # https://opennmt.net/CTranslate2/python/overview.html
    "ctranslate2"
    "ctranslate2.converters"
    "ctranslate2.models"
    "ctranslate2.specs"
  ];

  # https://github.com/OpenNMT/CTranslate2/tree/master/python
  sourceRoot = "${src.name}/python";

  meta = {
    description = "Fast inference engine for Transformer models";
    homepage = "https://github.com/OpenNMT/CTranslate2";
    changelog = "https://github.com/OpenNMT/CTranslate2/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
