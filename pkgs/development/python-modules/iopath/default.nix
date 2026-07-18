{
  lib,
  fetchFromGitHub,
  boto3,
  buildPythonPackage,
  portalocker,
  # check inputs
  pytestCheckHook,
  torch,
  # build inputs
  tqdm,
}:
let
  pname = "iopath";
  version = "0.1.10";
in
buildPythonPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "facebookresearch";
    repo = "iopath";
    tag = "v${version}";
    hash = "sha256-vJV0c+dCFO0wOHahKJ8DbwT2Thx3YjkNLVSpQv9H69g=";
  };

  propagatedBuildInputs = [
    tqdm
    portalocker
  ];

  nativeCheckInputs = [
    pytestCheckHook
    torch
  ];

  disabledTestPaths = [
    # flakey
    "tests/async_torch_test.py"
    "tests/async_writes_test.py"
  ];

  disabledTests = [
    # requires network access
    "test_download"
    "test_bad_args"
  ];

  format = "setuptools";

  optional-dependencies = {
    aws = [ boto3 ];
  };

  pythonImportsCheck = [ "iopath" ];

  meta = {
    description = "Python library that provides common I/O interface across different storage backends";
    homepage = "https://github.com/facebookresearch/iopath";
    changelog = "https://github.com/facebookresearch/iopath/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ happysalada ];
  };
}
