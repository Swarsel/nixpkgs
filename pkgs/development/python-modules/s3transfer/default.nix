{
  lib,
  stdenv,
  fetchFromGitHub,
  botocore,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "s3transfer";
  version = "0.16.0";

  src = fetchFromGitHub {
    owner = "boto";
    repo = "s3transfer";
    tag = version;
    hash = "sha256-dpDlsZtLjd6r4kLkIDPG6ZPFFs6/4elYiHk2HDpa9+4=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    botocore
  ];

  disabledTestPaths = [
    # Requires network access
    "tests/integration"
  ]
  ++
    # There was a change in python 3.8 that defaults multiprocessing to spawn instead of fork on macOS
    # See https://bugs.python.org/issue33725 and https://github.com/python/cpython/pull/13603.
    # I suspect the underlying issue here is that upstream tests aren't compatible with spawn multiprocessing, and pass on linux where the default is still fork
    lib.optionals stdenv.hostPlatform.isDarwin [ "tests/unit/test_compat.py" ];

  optional-dependencies = {
    crt = botocore.optional-dependencies.crt;
  };

  pyproject = true;
  pythonImportsCheck = [ "s3transfer" ];

  meta = {
    description = "Library for managing Amazon S3 transfers";
    homepage = "https://github.com/boto/s3transfer";
    changelog = "https://github.com/boto/s3transfer/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nickcao ];
  };
}
