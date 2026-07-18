{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  hatchling,
  pytest-asyncio,
  pytest-vcr,
  pytestCheckHook,
  vcrpy,
  yarl,
}:

buildPythonPackage (finalAttrs: {
  pname = "asyncprawcore";
  version = "4.0.0";

  src = fetchFromGitHub {
    owner = "praw-dev";
    repo = "asyncprawcore";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kpqd6H8uiqp4rM+8B+qJxfslrY5uvRTEARwh/0runIg=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pytest-vcr
    vcrpy
  ];

  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    yarl
  ];

  disabledTestPaths = [
    # Ignored due to error with request cannot pickle 'BufferedReader' instances
    # Upstream issue: https://github.com/kevin1024/vcrpy/issues/737
    "tests/integration/test_sessions.py"
  ];

  disabledTests = [
    # Test requires network access
    "test_initialize"
  ];

  pyproject = true;
  pythonImportsCheck = [ "asyncprawcore" ];

  meta = {
    description = "Low-level asynchronous communication layer for Async PRAW";
    homepage = "https://asyncpraw.readthedocs.io/";
    changelog = "https://github.com/praw-dev/asyncprawcore/blob/v${finalAttrs.version}/CHANGES.rst";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.amadejkastelic ];
  };
})
