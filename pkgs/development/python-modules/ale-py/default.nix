{
  lib,
  stdenv,
  fetchFromGitHub,
  # buildInputs
  SDL2,
  buildPythonPackage,
  # tests
  chex,
  # build-system
  cmake,
  config,
  # nativeBuildInputs
  cudaPackages,
  gymnasium,
  # linux-only
  jax,
  nanobind,
  ninja,
  # dependencies
  numpy,
  opencv,
  pytestCheckHook,
  scikit-build-core,
  zlib,
}:

buildPythonPackage (finalAttrs: {
  pname = "ale-py";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "Farama-Foundation";
    repo = "Arcade-Learning-Environment";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hFbreHk0i4h+JOyvDYcNX3TmwgvxNC5U0l5Xrqqz1zQ=";
  };

  # disable lto on darwin, cmake cannot find llvm-ar
  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace src/ale/CMakeLists.txt \
      --replace-fail \
        'set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)' \
        'set(CMAKE_INTERPROCEDURAL_OPTIMIZATION FALSE)'
  '';

  nativeBuildInputs = lib.optionals config.cudaSupport [
    # Required by opencv's cmake
    cudaPackages.cuda_nvcc
  ];

  buildInputs = [
    SDL2
    zlib
    opencv
  ];

  nativeCheckInputs = [
    chex
    gymnasium
    pytestCheckHook
  ];

  __structuredAttrs = true;

  build-system = [
    cmake
    ninja
    scikit-build-core
    nanobind
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    jax
  ];

  dependencies = [
    numpy
  ];

  disabledTestPaths = [
    "tests/python/test_atari_vector_xla.py"
  ];

  disabledTests = [
    # Fatal Python error: Aborted
    # line 414 in test_display_screen
    "test_display_screen"

    # Most Atari tests fail because the ROM are missing.
    # The user is expected to manually download the roms:
    # https://github.com/Farama-Foundation/Arcade-Learning-Environment/blob/v0.9.0/docs/faq.md#i-downloaded-ale-and-i-installed-it-successfully-but-i-cannot-find-any-rom-file-at-roms-do-i-have-to-get-them-somewhere-else
    "TestVectorEnv"
    "test_check_env"
    "test_clone_pickle_restore_new_env"
    "test_clone_restore"
    "test_continuous_actions"
    "test_determinism"
    "test_gym_keys_to_action"
    "test_jit"
    "test_obs_params"
    "test_reset_step_shapes"
    "test_rollout_consistency"
    "test_seeding"
    "test_sound_obs"
    "test_state_serialize_roundtrip"
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "ale_py" ];

  meta = {
    description = "Simple framework that allows researchers and hobbyists to develop AI agents for Atari 2600 games";
    homepage = "https://github.com/mgbellemare/Arcade-Learning-Environment";
    changelog = "https://github.com/Farama-Foundation/Arcade-Learning-Environment/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ billhuang ];
    mainProgram = "ale-import-roms";
  };
})
