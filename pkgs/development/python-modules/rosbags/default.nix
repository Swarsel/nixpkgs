{
  lib,
  fetchFromGitLab,
  buildPythonPackage,
  # checkInputs
  declinate,
  # dependencies
  lz4,
  numpy,
  # nativeCheckInputs
  pytestCheckHook,
  pythonAtLeast,
  ruamel-yaml,
  safelz4,
  # build-system
  setuptools,
  setuptools-scm,
  typing-extensions,
  zstandard,
}:

buildPythonPackage rec {
  pname = "rosbags";
  version = "0.11.0";

  src = fetchFromGitLab {
    owner = "ternaris";
    repo = "rosbags";
    tag = "v${version}";
    hash = "sha256-CSRJIGLhQwuaGatfWIbnYNdjUva+klBYPyDbjHfUNlM=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  checkInputs = [
    declinate
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    lz4
    numpy
    ruamel-yaml
    typing-extensions
    zstandard
  ]
  ++ lib.optional (pythonAtLeast "3.14") safelz4;

  pyproject = true;

  pythonImportsCheck = [
    "rosbags"
  ];

  meta = {
    description = "Pure Python library to read, modify, convert, and write rosbag files";
    homepage = "https://gitlab.com/ternaris/rosbags";
    changelog = "https://gitlab.com/ternaris/rosbags/-/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nim65s ];
  };
}
