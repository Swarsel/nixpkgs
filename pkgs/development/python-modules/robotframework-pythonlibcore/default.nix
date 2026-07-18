{
  lib,
  fetchFromGitHub,
  approvaltests,
  buildPythonPackage,
  pytest-mockito,
  pytestCheckHook,
  robotframework,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "robotframework-pythonlibcore";
  version = "4.6.0";

  src = fetchFromGitHub {
    owner = "robotframework";
    repo = "PythonLibCore";
    tag = "v${version}";
    hash = "sha256-H13b25M4vEymXZzhAm/EXMx7v5u/9rgkBXv7nBaxAvo=";
  };

  nativeCheckInputs = [
    approvaltests
    pytest-mockito
    pytestCheckHook
    typing-extensions
  ];

  build-system = [ setuptools ];
  dependencies = [ robotframework ];
  pyproject = true;
  pythonImportsCheck = [ "robotlibcore" ];

  meta = {
    description = "Tools to ease creating larger test libraries for Robot Framework using Python";
    homepage = "https://github.com/robotframework/PythonLibCore";
    changelog = "https://github.com/robotframework/PythonLibCore/blob/${src.tag}/docs/PythonLibCore-${src.tag}.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
