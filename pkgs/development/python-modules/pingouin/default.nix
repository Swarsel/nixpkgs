{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  matplotlib,
  # optional dependencies
  mpmath,
  numpy,
  pandas,
  pandas-flavor,
  # test framework
  pytestCheckHook,
  scikit-learn,
  scipy,
  seaborn,
  # build-system
  setuptools,
  statsmodels,
  tabulate,
}:

buildPythonPackage (finalAttrs: {
  pname = "pingouin";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "raphaelvallat";
    repo = "pingouin";
    tag = "v${finalAttrs.version}";
    hash = "sha256-22nVAw6qbYwumwVJr/ZZD2HSpgD+9onnMe/hULjQHZI=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ finalAttrs.passthru.optional-dependencies.extras;

  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    matplotlib
    numpy
    pandas
    pandas-flavor
    scikit-learn
    scipy
    seaborn
    statsmodels
    tabulate
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pingouin"
  ];

  passthru.optional-dependencies = {
    extras = [
      mpmath
    ];
  };

  meta = {
    description = "Statistical package in Python based on Pandas";
    homepage = "https://github.com/raphaelvallat/pingouin";
    changelog = "https://github.com/raphaelvallat/pingouin/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ grandjeanlab ];
  };
})
