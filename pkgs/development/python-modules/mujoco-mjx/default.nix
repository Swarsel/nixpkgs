{
  lib,
  # dependencies
  absl-py,
  buildPythonPackage,
  etils,
  importlib-resources,
  jax,
  jaxlib,
  mujoco,
  # src / metadata
  mujoco-main,
  scipy,
  # build-system
  setuptools,
  trimesh,
}:

buildPythonPackage {
  inherit (mujoco-main) src version;
  pname = "mujoco-mjx";
  build-system = [ setuptools ];

  dependencies = [
    absl-py
    etils
    importlib-resources
    jax
    jaxlib
    mujoco
    scipy
    trimesh
  ]
  ++ etils.optional-dependencies.epath;

  pyproject = true;
  pythonImportsCheck = [ "mujoco.mjx" ];
  sourceRoot = "${mujoco-main.src.name}/mjx";

  meta = {
    inherit (mujoco.meta) homepage changelog license;
    description = "MuJoCo XLA (MJX)";
    maintainers = with lib.maintainers; [ nim65s ];
  };
}
