{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  certifi,
  charset-normalizer,
  courlan,
  htmldate,
  justext,
  lxml,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
  urllib3,
}:

buildPythonPackage (finalAttrs: {
  pname = "trafilatura";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "adbar";
    repo = "trafilatura";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hSeJH+8JX8QC3zHMZ3+M2H0C3xI+BCvLnSo/Ih1wUQw=";
  };

  postPatch =
    # nixify path to the trafilatura binary in the test suite
    ''
      substituteInPlace tests/cli_tests.py \
        --replace-fail \
          'trafilatura_bin = "trafilatura"' \
          'trafilatura_bin = "${placeholder "out"}/bin/trafilatura"'
    '';

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    certifi
    charset-normalizer
    courlan
    htmldate
    justext
    lxml
    urllib3
  ];

  disabledTests = [
    # Disable tests that require an internet connection
    "test_cli_pipeline"
    "test_crawl_page"
    "test_download"
    "test_feeds_helpers"
    "test_fetch"
    "test_input_type"
    "test_is_live_page"
    "test_meta_redirections"
    "test_probing"
    "test_queue"
    "test_redirection"
    "test_whole"
  ];

  pyproject = true;
  pythonImportsCheck = [ "trafilatura" ];

  pythonRelaxDeps = [
    "lxml"
  ];

  meta = {
    description = "Python package and command-line tool designed to gather text on the Web";
    homepage = "https://trafilatura.readthedocs.io";
    changelog = "https://github.com/adbar/trafilatura/blob/${finalAttrs.src.tag}/HISTORY.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jokatzke ];
    mainProgram = "trafilatura";
    downloadPage = "https://github.com/adbar/trafilatura";
  };
})
