{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "simple-pid";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "m-lundberg";
    repo = "simple-pid";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DKi0ODnhoY/Pqzd6Zlvd1gMlFtzivigO0xThz35TBf8=";
  };

  doCheck = !stdenv.isDarwin;

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  pyproject = true;

  pythonImportsCheck = [
    "simple_pid"
  ];

  meta = {
    description = "A simple and easy to use PID controller in Python";
    homepage = "https://github.com/m-lundberg/simple-pid";
    changelog = "https://github.com/m-lundberg/simple-pid/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
