{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  huggingface-hub,
  onnxruntime,
  sentencepiece,
  # build-system
  setuptools,
  torch,
  tqdm,
  transformers,
}:

buildPythonPackage (finalAttrs: {
  pname = "gliner";
  version = "0.2.27";

  src = fetchFromGitHub {
    owner = "urchade";
    repo = "GLiNER";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pM2JenMxBvCiDQyj9VFMYJGRckWJWna3gCdAlhBGR1U=";
  };

  # All tests require internet
  doCheck = false;
  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    huggingface-hub
    onnxruntime
    sentencepiece
    torch
    tqdm
    transformers
  ];

  pyproject = true;

  # aarch64-linux fails cpuinfo test, because /sys/devices/system/cpu/ does not exist in the sandbox:
  # terminate called after throwing an instance of 'onnxruntime::OnnxRuntimeException'
  #
  # -> Skip the import check
  pythonImportsCheck =
    lib.optionals (!(stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64))
      [
        "gliner"
      ];

  pythonRelaxDeps = [
    "transformers"
  ];

  meta = {
    description = "Generalist and Lightweight Model for Named Entity Recognition";
    homepage = "https://github.com/urchade/GLiNER";
    changelog = "https://github.com/urchade/GLiNER/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];

    badPlatforms = [
      # terminate called after throwing an instance of 'onnxruntime::OnnxRuntimeException'
      # Attempt to use DefaultLogger but none has been registered.
      # "aarch64-linux"
    ];
  };
})
