{
  lib,
  fetchFromGitHub,
  annotated-types,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  logfury,
  pytest-lazy-fixtures,
  pytest-mock,
  pytest-timeout,
  pytestCheckHook,
  pythonAtLeast,
  pythonOlder,
  requests,
  responses,
  tenacity,
  tqdm,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "b2sdk";
  version = "2.12.0";

  src = fetchFromGitHub {
    owner = "Backblaze";
    repo = "b2-sdk-python";
    tag = "v${version}";
    hash = "sha256-JzJ83+W9k5ys8dj0Q3X4MY+GH4m8/crvKmeQKOttspM=";
  };

  nativeCheckInputs = [
    pytest-lazy-fixtures
    pytest-mock
    pytest-timeout
    pytestCheckHook
    responses
    tenacity
    tqdm
  ];

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    annotated-types
    logfury
    requests
  ]
  ++ lib.optionals (pythonOlder "3.12") [ typing-extensions ];

  disabledTests = lib.optionals (pythonAtLeast "3.14") [
    # -     'could not be accessed (no permissions to read?)',
    # +     'could not be accessed (broken symlink?)',
    "test_dir_without_exec_permission"
  ];

  enabledTestPaths = [
    "test/unit"
  ];

  pyproject = true;
  pythonImportsCheck = [ "b2sdk" ];

  meta = {
    description = "Client library and utilities for access to B2 Cloud Storage (backblaze)";
    homepage = "https://github.com/Backblaze/b2-sdk-python";
    changelog = "https://github.com/Backblaze/b2-sdk-python/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pmw ];
  };
}
