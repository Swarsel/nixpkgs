{
  lib,
  fetchFromGitHub,
  anyio,
  beartype,
  buildPythonPackage,
  deprecated,
  exceptiongroup,
  hatch-mypyc,
  hatch-vcs,
  hatchling,
  packaging,
  pytest-asyncio,
  pytest-lazy-fixtures,
  pytest-mock,
  pytestCheckHook,
  redis,
  types-deprecated,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "coredis";
  version = "6.6.1";

  src = fetchFromGitHub {
    owner = "alisaifee";
    repo = "coredis";
    tag = finalAttrs.version;
    hash = "sha256-Jn6tqMpyk849/hwYM0DHuQnGbMltRpTXAVcN5Kt6lk4=";
  };

  postPatch = ''
    sed -i '/mypy==/d' pyproject.toml
    sed -i '/hatch-mypy/d' pyproject.toml
    sed -i '/opentelemetry-sdk/d' pyproject.toml
    substituteInPlace pyproject.toml \
      --replace-fail '"-K"' ""
  '';

  nativeCheckInputs = [
    pytestCheckHook
    redis
    pytest-asyncio
    pytest-lazy-fixtures
    pytest-mock
  ];

  build-system = [
    hatchling
    hatch-mypyc
    hatch-vcs
    types-deprecated
  ];

  dependencies = [
    anyio
    beartype
    deprecated
    exceptiongroup
    packaging
    typing-extensions
  ];

  enabledTestPaths = [
    # All other tests require Docker
    "tests/test_lru_cache.py"
    "tests/test_parsers.py"
    "tests/test_retry.py"
    "tests/test_utils.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "coredis" ];

  meta = {
    description = "Async redis client with support for redis server, cluster & sentinel";
    homepage = "https://github.com/alisaifee/coredis";
    changelog = "https://github.com/alisaifee/coredis/blob/${finalAttrs.src.tag}/HISTORY.rst";
    license = lib.licenses.mit;
  };
})
