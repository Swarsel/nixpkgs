{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gym,
  gym-notices,
  gymnasium,
  matplotlib,
  moviepy,
  numpy,
  opencv4,
  pyglet,
  pytestCheckHook,
  pythonOlder,
  pyyaml,
  setuptools,
  shimmy,
  six,
  torch,
  tqdm,
}:

buildPythonPackage rec {
  pname = "vmas";
  version = "1.5.2";

  src = fetchFromGitHub {
    owner = "proroklab";
    repo = "VectorizedMultiAgentSimulator";
    tag = version;
    hash = "sha256-i1dr65IPIOGAH/1jXS7+PnxJzl986+fGB7M4ydisIrs=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pyyaml
    tqdm
  ]
  ++ optional-dependencies.gymnasium;

  build-system = [ setuptools ];

  dependencies = [
    gym
    gym-notices
    numpy
    pyglet
    six
    torch
  ];

  # dependency "gym" broken
  disabled = pythonOlder "3.12";

  disabledTests = [
    # pyglet.display.xlib.NoSuchDisplayException: Cannot connect to "None"
    "test_use_vmas_env"
    # Missing python3Packages.cvxpylayers
    "test_heuristic"
  ];

  optional-dependencies = {
    gymnasium = [
      gymnasium
      shimmy
    ];

    render = [
      matplotlib
      moviepy
      opencv4
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "vmas" ];

  pythonRelaxDeps = [
    "gym-notices"
    "pyglet"
  ];

  meta = {
    description = "A vectorized differentiable simulator designed for efficient Multi-Agent Reinforcement Learning benchmarking";
    homepage = "https://github.com/proroklab/VectorizedMultiAgentSimulator";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ derdennisop ];
  };
}
