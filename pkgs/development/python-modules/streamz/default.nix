{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  dask,
  distributed,
  flaky,
  pandas,
  pyarrow,
  pytest-asyncio,
  pytestCheckHook,
  # build-system
  setuptools,
  # dependencies
  toolz,
  tornado,
  zict,
}:

buildPythonPackage (finalAttrs: {
  pname = "streamz";
  version = "0.6.6";

  src = fetchFromGitHub {
    owner = "python-streamz";
    repo = "streamz";
    tag = finalAttrs.version;
    hash = "sha256-m+kBRz3K5W5yuLRcamWCZ6j6A3MBT3HyjuCLzIzUqak=";
  };

  nativeCheckInputs = [
    dask
    distributed
    flaky
    pandas
    pyarrow
    pytest-asyncio
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    toolz
    tornado
    zict
  ];

  disabledTests = [
    # Error with distutils version: fixture 'cleanup' not found
    "test_separate_thread_without_time"
    "test_await_syntax"
    "test_partition_then_scatter_sync"
    "test_sync"
    "test_sync_2"

    # Tests are flaky
    "test_buffer"
    "test_partition_timeout_cancel"
  ];

  pyproject = true;
  pythonImportsCheck = [ "streamz" ];

  meta = {
    description = "Pipelines to manage continuous streams of data";
    homepage = "https://github.com/python-streamz/streamz";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
