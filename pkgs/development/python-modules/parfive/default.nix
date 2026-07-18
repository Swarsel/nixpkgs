{
  lib,
  fetchFromGitHub,
  # dependencies
  aiofiles,
  # optional dependencies
  aioftp,
  aiohttp,
  buildPythonPackage,
  # tests
  pytest-asyncio,
  pytest-localserver,
  pytest-socket,
  pytestCheckHook,
  # build-system
  setuptools-scm,
  tqdm,
}:

buildPythonPackage (finalAttrs: {
  pname = "parfive";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "Cadair";
    repo = "parfive";
    tag = "v${finalAttrs.version}";
    hash = "sha256-i9B860A27KDUJKlE/eQNiGVPEPvnmvmNqMjjdOeBcyY=";
  };

  nativeCheckInputs = [
    aiofiles
    pytest-asyncio
    pytest-localserver
    pytest-socket
    pytestCheckHook
  ];

  # Tests require local network access
  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools-scm ];

  dependencies = [
    aiohttp
    tqdm
  ];

  disabledTestPaths = [
    # Tests that fail due to network access
    "parfive/tests/test_downloader.py"
    "parfive/tests/test_downloader_multipart.py"
    # assert 1 == 0
    "parfive/tests/test_main.py::test_run_cli_success"
    #  aiohttp.client_exceptions.ClientResponseError: 400, message="Data after `Connection: close
    "parfive/tests/test_utils.py::test_head_or_get"
    "parfive/tests/test_utils.py::test_head_302"
  ];

  disabledTests = [
    # Requires network access
    "test_ftp"
    "test_ftp_pasv_command"
    "test_ftp_http"
    "test_problematic_http_urls"

    # flaky comparison between runtime types
    "test_http_callback_fail"
  ];

  optional-dependencies = {
    ftp = [ aioftp ];
  };

  pyproject = true;

  pytestFlags = [
    # https://github.com/Cadair/parfive/issues/65
    "-Wignore::ResourceWarning"
  ];

  pythonImportsCheck = [ "parfive" ];

  meta = {
    description = "HTTP and FTP parallel file downloader";
    homepage = "https://parfive.readthedocs.io/";
    changelog = "https://github.com/Cadair/parfive/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sarahec ];
    mainProgram = "parfive";
  };
})
