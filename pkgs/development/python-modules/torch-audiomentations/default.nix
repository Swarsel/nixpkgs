{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  julius,
  librosa,
  # tests
  pytest-cov-stub,
  pytestCheckHook,
  pyyaml,
  # build-system
  setuptools,
  torch,
  torch-pitch-shift,
  torchaudio,
}:

buildPythonPackage (finalAttrs: {
  pname = "torch-audiomentations";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "asteroid-team";
    repo = "torch-audiomentations";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5ccVO1ECiIn0q7m8ZLHxqD2fhaXeMDKUEswa49dRTsY=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
    pyyaml
  ];

  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    julius
    librosa
    torch
    torch-pitch-shift
    torchaudio
  ];

  disabledTestPaths = [
    # librosa issues
    "tests/test_mix.py"
    "tests/test_convolution.py"
    "tests/test_impulse_response.py"
    "tests/test_background_noise.py"
  ];

  disabledTests = [
    # AttributeError: module 'torchaudio' has no attribute 'info'
    # Removed in torchaudio v2.9.0
    # See https://github.com/pytorch/audio/issues/3902 for context
    # Reported to torch-audiomentations: https://github.com/iver56/torch-audiomentations/issues/184
    "test_background_noise_no_guarantee_with_empty_tensor"
    "test_colored_noise_guaranteed_with_batched_tensor"
    "test_colored_noise_guaranteed_with_single_tensor"
    "test_colored_noise_guaranteed_with_zero_length_samples"
    "test_colored_noise_no_guarantee_with_single_tensor"
    "test_same_min_max_f_decay"
    "test_transform_is_differentiable"
  ];

  pyproject = true;
  pythonImportsCheck = [ "torch_audiomentations" ];
  pythonRelaxDeps = [ "torchaudio" ];

  meta = {
    description = "Fast audio data augmentation in PyTorch";
    homepage = "https://github.com/asteroid-team/torch-audiomentations";
    changelog = "https://github.com/asteroid-team/torch-audiomentations/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ matthewcroughan ];
  };
})
