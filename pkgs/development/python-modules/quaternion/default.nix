{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  hatchling,
  numpy,
  # tests
  pytest-cov-stub,
  pytestCheckHook,
  # dependencies
  scipy,
  setuptools,
}:

buildPythonPackage rec {
  pname = "quaternion";
  version = "2024.0.13";

  src = fetchFromGitHub {
    owner = "moble";
    repo = "quaternion";
    tag = "v${version}";
    hash = "sha256-W35R+S6yzcKTpKtemjiLzH9v5owduUtos9DyoY28qbc=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [
    hatchling
    numpy
    setuptools
  ];

  dependencies = [
    numpy
    scipy
  ];

  pyproject = true;
  pythonImportsCheck = [ "quaternion" ];

  meta = {
    description = "Package add built-in support for quaternions to numpy";
    homepage = "https://github.com/moble/quaternion";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ocfox ];
  };
}
