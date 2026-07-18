{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "onecache";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "sonic182";
    repo = "onecache";
    tag = version;
    hash = "sha256-jhyszGKzmMdtPfnjc3VllfF6Zd0MkV66CpL6HiAof/A=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    pytest-asyncio
  ];

  build-system = [ poetry-core ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # test fails due to unknown reason on darwin
    "test_lru_and_ttl_refresh"
  ];

  pyproject = true;
  pythonImportsCheck = [ "onecache" ];

  meta = {
    description = "Python LRU and TTL cache for sync and async code";
    homepage = "https://github.com/sonic182/onecache";
    changelog = "https://github.com/sonic182/onecache/blob/${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ geraldog ];
  };
}
