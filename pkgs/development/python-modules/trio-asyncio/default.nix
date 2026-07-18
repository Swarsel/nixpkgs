{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  greenlet,
  outcome,
  pytest-trio,
  pytestCheckHook,
  pythonAtLeast,
  setuptools,
  sniffio,
  trio,
}:

buildPythonPackage rec {
  pname = "trio-asyncio";
  version = "0.16.0";

  src = fetchFromGitHub {
    owner = "python-trio";
    repo = "trio-asyncio";
    tag = "v${version}";
    hash = "sha256-7kp99tdJhExjg8WsfBtXJyFrKnSAtTF1fhPFxCU7eI8=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail '"pytest-runner"' ""
  '';

  nativeCheckInputs = [
    pytest-trio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    greenlet
    trio
    outcome
    sniffio
  ];

  # https://github.com/python-trio/trio-asyncio/issues/160
  disabled = pythonAtLeast "3.14";

  disabledTests = [
    # TypeError: RaisesGroup.__init__() got an unexpected keyword argument 'strict'
    # https://github.com/python-trio/trio-asyncio/issues/154
    "test_run_trio_task_errors"
    "test_cancel_loop_with_tasks"
  ];

  pyproject = true;

  pytestFlags = [
    # RuntimeWarning: Can't run the Python asyncio tests because they're not installed
    "-Wignore::RuntimeWarning"
    "-Wignore::DeprecationWarning"
  ];

  pythonImportsCheck = [ "trio_asyncio" ];

  meta = {
    description = "Re-implementation of the asyncio mainloop on top of Trio";
    homepage = "https://github.com/python-trio/trio-asyncio";
    changelog = "https://github.com/python-trio/trio-asyncio/blob/v${version}/docs/source/history.rst";

    license = with lib.licenses; [
      asl20 # or
      mit
    ];

    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
