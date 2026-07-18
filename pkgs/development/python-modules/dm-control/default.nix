{
  lib,
  fetchFromGitHub,
  # build-system
  absl-py,
  buildPythonPackage,
  # dependencies
  dm-env,
  dm-tree,
  etils,
  fsspec,
  glfw,
  h5py,
  lxml,
  mock,
  mujoco,
  numpy,
  pillow,
  protobuf,
  pyopengl,
  pyparsing,
  requests,
  scipy,
  setuptools,
  tqdm,
}:

buildPythonPackage (finalAttrs: {
  pname = "dm-control";
  version = "1.0.43";

  src = fetchFromGitHub {
    owner = "google-deepmind";
    repo = "dm_control";
    tag = finalAttrs.version;
    hash = "sha256-6c67sOcKsygtjdn3NOjfK0K3IsZIOZHDMXr5qMp+W5A=";
  };

  # The installed library clashes with the `dm_control` directory remaining in the source path.
  # Usually, we get around this by `rm -rf` the python source files to ensure that the installed package is used.
  # Here, we cannot do that as it would also remove the tests which are also in the `dm_control` directory.
  # See https://github.com/google-deepmind/dm_control/issues/6
  doCheck = false;
  __structuredAttrs = true;

  build-system = [
    absl-py
    mujoco
    pyparsing
    setuptools
  ];

  dependencies = [
    absl-py
    dm-env
    dm-tree
    fsspec
    glfw
    h5py
    lxml
    mock
    mujoco
    numpy
    pillow
    protobuf
    pyopengl
    pyparsing
    requests
    scipy
    setuptools
    tqdm
  ]
  ++ etils.optional-dependencies.epath;

  pyproject = true;
  pythonImportsCheck = [ "dm_control" ];

  pythonRemoveDeps = [
    # Unpackaged
    "labmaze"
  ];

  meta = {
    description = "Google DeepMind's software stack for physics-based simulation and Reinforcement Learning environments, using MuJoCo";
    homepage = "https://github.com/google-deepmind/dm_control";
    changelog = "https://github.com/google-deepmind/dm_control/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
