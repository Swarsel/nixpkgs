{
  lib,
  stdenv,
  fetchFromGitHub,
  ale-py,
  buildPythonPackage,
  cython,
  # dependencies
  deepdiff,
  # optional-dependencies
  docstring-parser,
  gymnasium,
  h5py,
  imageio,
  joblib,
  jsonargparse,
  matplotlib,
  mujoco,
  numba,
  numpy,
  opencv,
  overrides,
  packaging,
  pandas,
  pettingzoo,
  # build-system
  poetry-core,
  pybox2d,
  pybullet,
  pygame,
  # tests
  pymunk,
  pytestCheckHook,
  scipy,
  sensai-utils,
  shimmy,
  swig,
  tensorboard,
  torch,
  tqdm,
}:

buildPythonPackage rec {
  pname = "tianshou";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "thu-ml";
    repo = "tianshou";
    tag = "v${version}";
    hash = "sha256-loE2klM989yZbPZ3Uun3xnGsDHrEZhzk1R0/PcH/1nM=";
  };

  postPatch = ''
    # silence matplotlib warning
    export MPLCONFIGDIR=$(mktemp -d)
  '';

  nativeCheckInputs = [
    pygame
    pymunk
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    deepdiff
    gymnasium
    h5py
    matplotlib
    numba
    numpy
    overrides
    packaging
    pandas
    pettingzoo
    sensai-utils
    tensorboard
    torch
    tqdm
  ];

  disabledTestPaths = [
    # remove tests that require lot of compute (ai model training tests)
    "test/continuous"
    "test/discrete"
    "test/highlevel"
    "test/modelbased"
    "test/offline"
  ];

  disabledTests = [
    # AttributeError: 'TimeLimit' object has no attribute 'test_attribute'
    "test_attr_unwrapped"
    # Failed: DID NOT RAISE <class 'TypeError'>
    "test_batch"
    # Failed: Raised AssertionError
    "test_vecenv"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # Fatal Python error: Aborted
    # pettingzoo/classic/tictactoe/tictactoe.py", line 254 in reset
    "test_tic_tac_toe"
  ];

  optional-dependencies = {
    all = lib.concatAttrValues (lib.removeAttrs optional-dependencies [ "all" ]);

    argparse = [
      docstring-parser
      jsonargparse
    ];

    atari = [
      ale-py
      # autorom
      opencv
      shimmy
    ];

    box2d = [
      # instead of box2d-py
      pybox2d
      pygame
      swig
    ];

    classic_control = [
      pygame
    ];

    # envpool = [
    #   envpool
    # ];
    # robotics = [
    #   gymnasium-robotics
    # ];
    # vizdoom = [
    #   vizdoom
    # ];
    eval = [
      docstring-parser
      joblib
      jsonargparse
      # rliable
      scipy
    ];

    mujoco = [
      mujoco
      imageio
      cython
    ];

    pybullet = [
      pybullet
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "tianshou" ];

  pythonRelaxDeps = [
    "deepdiff"
    "gymnasium"
    "numpy"
  ];

  pythonRemoveDeps = [ "virtualenv" ];

  meta = {
    description = "Elegant PyTorch deep reinforcement learning library";
    homepage = "https://github.com/thu-ml/tianshou";
    changelog = "https://github.com/thu-ml/tianshou/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ derdennisop ];
  };
}
