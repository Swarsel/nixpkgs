{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  config,
  # dependencies
  fire,
  # tests
  mamba-ssm,
  mistral-common,
  # passthu
  mistral-inference,
  pillow,
  # build-system
  poetry-core,
  pycountry,
  pytestCheckHook,
  pythonAtLeast,
  safetensors,
  simple-parsing,
  writableTmpDirAsHomeHook,
  xformers,
}:

buildPythonPackage (finalAttrs: {
  pname = "mistral-inference";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "mistralai";
    repo = "mistral-inference";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dcBlZWrgQn7eiNsjTS8882X9quHbgTfXxTK7HLpbLM8=";
  };

  # Tests require GPU access in the sandbox
  doCheck = false;

  nativeCheckInputs = [
    mamba-ssm
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  build-system = [
    poetry-core
  ];

  dependencies = [
    fire
    mistral-common
    pillow
    pycountry
    safetensors
    simple-parsing
    xformers
  ];

  disabledTests = lib.optionals (pythonAtLeast "3.14") [
    # AttributeError("module 'ast' has no attribute 'Num'")
    "test_generation_mamba"
  ];

  pyproject = true;
  pythonImportsCheck = [ "mistral_inference" ];

  passthru.gpuCheck = mistral-inference.overridePythonAttrs {
    doCheck = true;
    requiredSystemFeatures = [ "cuda" ];
  };

  meta = {
    description = "High-performance library for running Mistral AI models on local hardware";
    homepage = "https://github.com/mistralai/mistral-inference";
    changelog = "https://github.com/mistralai/mistral-inference/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      GaetanLepage
      mana-byte
    ];

    platforms = lib.platforms.linux;
    mainProgram = "mistral-chat";
    # Explicitly requires an NVIDIA GPU to work
    broken = !config.cudaSupport;
  };
})
