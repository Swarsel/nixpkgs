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
  pname = "cloudpickle";
  version = "3.1.2";

  src = fetchFromGitHub {
    owner = "cloudpipe";
    repo = "cloudpickle";
    tag = "v${version}";
    hash = "sha256-BsCOEpNCNqq8PS+SdbzF1wq0LXEmtcHJs0pdt2qFw/w=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ flit-core ];

  disabledTestPaths = [
    # ModuleNotFoundError: No module named 'psutil'
    # (because _make_cwd_env() overwrites $PYTHONPATH)
    "tests/cloudpickle_test.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "cloudpickle" ];

  meta = {
    description = "Extended pickling support for Python objects";
    homepage = "https://github.com/cloudpipe/cloudpickle";
    changelog = "https://github.com/cloudpipe/cloudpickle/blob/${src.tag}/CHANGES.md";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
