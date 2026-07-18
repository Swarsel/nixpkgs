{
  lib,
  fetchFromGitHub,
  aiofiles,
  aiohttp,
  asyncprawcore,
  buildPythonPackage,
  coverage,
  defusedxml,
  hatchling,
  pytest-asyncio,
  pytest-vcr,
  pytestCheckHook,
  update-checker,
  vcrpy,
}:

buildPythonPackage (finalAttrs: {
  pname = "asyncpraw";
  version = "8.0.1";

  src = fetchFromGitHub {
    owner = "praw-dev";
    repo = "asyncpraw";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lVRIZP9XsUEM1Czl4YC10EdSC8RmO5ugPgo3THyqi9A=";
  };

  nativeCheckInputs = [
    coverage
    pytestCheckHook
    pytest-asyncio
    pytest-vcr
    vcrpy
  ];

  build-system = [ hatchling ];

  dependencies = [
    aiofiles
    aiohttp
    asyncprawcore
    defusedxml
    update-checker
  ];

  disabledTestPaths = [
    # Ignored due to error with request cannot pickle 'BufferedReader' instances
    # Upstream issue: https://github.com/kevin1024/vcrpy/issues/737
    "tests/integration/models/reddit/test_emoji.py"
    "tests/integration/models/reddit/test_submission.py"
    "tests/integration/models/reddit/test_subreddit.py"
    "tests/integration/models/reddit/test_widgets.py"
    "tests/integration/models/reddit/test_wikipage.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "asyncpraw" ];

  pythonRelaxDeps = [
    "defusedxml"
    "update-checker"
  ];

  meta = {
    description = "Asynchronous Python Reddit API Wrapper";
    homepage = "https://asyncpraw.readthedocs.io/";
    changelog = "https://github.com/praw-dev/asyncpraw/blob/${finalAttrs.src.rev}/CHANGES.rst";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.amadejkastelic ];
  };
})
