{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  lxml,
  numpy,
  pytest-cov-stub,
  # nativeCheckInputs
  pytestCheckHook,
  # build-system
  setuptools,
  setuptools-scm,
  six,
  trimesh,
}:

buildPythonPackage (finalAttrs: {
  pname = "yourdfpy";
  version = "0.0.60";

  src = fetchFromGitHub {
    owner = "clemense";
    repo = "yourdfpy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tXFrwtxjLvHNxT/MhrAiV2CGcbKj1JRi/Yo8Qt6UBfk=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    lxml
    trimesh
    numpy
    six
  ];

  pyproject = true;

  pythonImportsCheck = [
    "yourdfpy"
  ];

  meta = {
    description = "Python parser for URDFs";
    homepage = "https://github.com/clemense/yourdfpy/";
    changelog = "https://github.com/clemense/yourdfpy/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nim65s ];
    mainProgram = "yourdfpy";
  };
})
