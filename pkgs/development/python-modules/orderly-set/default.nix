{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  flit-core,
  # tests
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "orderly-set";
  version = "5.5.0";

  src = fetchFromGitHub {
    owner = "seperman";
    repo = "orderly-set";
    tag = version;
    hash = "sha256-xrxH/LB+cyZlVf+sVwOtAf9+DojYPDnudHpqlVuARLg=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    flit-core
  ];

  disabledTests = [
    # Statically analyzes types, can be disabled so that mypy won't be needed.
    "test_typing_mypy"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "orderly_set"
  ];

  meta = {
    description = "Multiple implementations of Ordered Set";
    homepage = "https://github.com/seperman/orderly-set";
    changelog = "https://github.com/seperman/orderly-set/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
