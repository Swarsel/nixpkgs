{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pytest-aiohttp,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "aiojobs";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "aio-libs";
    repo = "aiojobs";
    tag = "v${version}";
    hash = "sha256-MgGUmDG0b0V/k+mCeiVRnBxa+ChK3URnGv6P8QP7RzQ=";
  };

  nativeBuildInputs = [ setuptools ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-aiohttp
    pytest-cov-stub
  ]
  ++ lib.concatAttrValues optional-dependencies;

  __darwinAllowLocalNetworking = true;

  disabledTests = [
    # RuntimeWarning: coroutine 'Scheduler._wait_failed' was never awaited
    "test_scheduler_must_be_created_within_running_loop"
  ];

  optional-dependencies = {
    aiohttp = [ aiohttp ];
  };

  pyproject = true;
  pythonImportsCheck = [ "aiojobs" ];

  meta = {
    description = "Jobs scheduler for managing background task (asyncio)";
    homepage = "https://github.com/aio-libs/aiojobs";
    changelog = "https://github.com/aio-libs/aiojobs/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ cmcdragonkai ];
  };
}
