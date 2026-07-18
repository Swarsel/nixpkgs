{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # runtime
  ffmpeg-headless,
  # dependencies
  more-itertools,
  numba,
  numpy,
  # tests
  pytestCheckHook,
  replaceVars,
  scipy,
  # build-system
  setuptools,
  tiktoken,
  torch,
  tqdm,
  triton,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "whisper";
  version = "20250625";

  src = fetchFromGitHub {
    owner = "openai";
    repo = "whisper";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Zn2HUCor1eCJBP7q0vpffqhw5SNguz8zCGoPgdt6P+c=";
  };

  patches = [
    (replaceVars ./ffmpeg-path.patch {
      ffmpeg = ffmpeg-headless;
    })
  ];

  nativeCheckInputs = [
    pytestCheckHook
    scipy
    writableTmpDirAsHomeHook
  ];

  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    more-itertools
    numba
    numpy
    tiktoken
    torch
    tqdm
  ]
  ++ lib.optionals (lib.meta.availableOn stdenv.hostPlatform triton) [ triton ];

  disabledTests = [
    # requires network access to download models
    "test_transcribe"

    # requires NVIDIA drivers
    "test_dtw_cuda_equivalence"
    "test_median_filter_equivalence"
  ]
  ++ lib.optionals (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64) [
    # Fatal Python error: Segmentation fault
    "test_dtw"
  ];

  pyproject = true;

  meta = {
    description = "General-purpose speech recognition model";
    homepage = "https://github.com/openai/whisper";
    changelog = "https://github.com/openai/whisper/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ MayNiklas ];
    mainProgram = "whisper";
  };
})
