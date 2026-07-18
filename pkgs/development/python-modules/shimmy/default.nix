{
  lib,
  fetchFromGitHub,
  # tests
  ale-py,
  bsuite,
  buildPythonPackage,
  dm-control,
  gym,
  # dependencies
  gymnasium,
  imageio,
  numpy,
  pettingzoo,
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "shimmy";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "Farama-Foundation";
    repo = "Shimmy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vMVvD/UNzGs6igYskQ/L+yt0v5kdjOVal0sfaTkirsU=";
  };

  nativeCheckInputs = [
    ale-py
    bsuite
    dm-control
    gym
    imageio
    pettingzoo
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    gymnasium
    numpy
  ];

  disabledTestPaths = [
    # Requires unpackaged labmaze
    "tests/test_dm_control_multi_agent.py"

    # Requires unpackaged pyspiel
    "tests/test_openspiel.py"
  ];

  disabledTests = [
    # Require network access
    "test_check_env[bsuite/mnist_noise-v0]"
    "test_check_env[bsuite/mnist_scale-v0]"
    "test_check_env[bsuite/mnist-v0]"
    "test_existing_env"
    "test_loading_env"
    "test_pickle[bsuite/mnist-v0]"
    "test_seeding[bsuite/mnist_noise-v0]"
    "test_seeding[bsuite/mnist_scale-v0]"
    "test_seeding[bsuite/mnist-v0]"
    "test_seeding"

    # RuntimeError: std::exception
    "test_check_env"
    "test_seeding[dm_control/quadruped-escape-v0]"
    "test_rendering_camera_id"
    "test_rendering_multiple_cameras"
    "test_rendering_depth"
    "test_render_height_widths"
  ];

  pyproject = true;
  pythonImportsCheck = [ "shimmy" ];

  meta = {
    description = "API conversion tool for popular external reinforcement learning environments";
    homepage = "https://github.com/Farama-Foundation/Shimmy";
    changelog = "https://github.com/Farama-Foundation/Shimmy/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
