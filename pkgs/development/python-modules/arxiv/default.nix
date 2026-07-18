{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  feedparser,
  hatch-vcs,
  # build-system
  hatchling,
  # tests
  mock,
  pytestCheckHook,
  requests,
}:
buildPythonPackage rec {
  pname = "arxiv";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "lukasschwab";
    repo = "arxiv.py";
    tag = version;
    hash = "sha256-o2Vqkr5Tlx7Iv1NEWDSU8X6hvlGUslIl4oHiRQNGdqI=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    mock
  ];

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    feedparser
    requests
  ];

  disabledTests = [
    # Require network access
    "test_from_feed_entry"
    "test_download_from_query"
    "test_download_tarfile_from_query"
    "test_download_with_custom_slugify_from_query"
    "test_get_short_id"
    "test_invalid_format_id"
    "test_invalid_id"
    "test_legacy_ids"
    "test_max_results"
    "test_missing_title"
    "test_no_duplicates"
    "test_nonexistent_id_in_list"
    "test_offset"
    "test_query_page_count"
    "test_result_shape"
    "test_search_results_offset"
  ];

  pyproject = true;
  pythonImportsCheck = [ "arxiv" ];

  meta = {
    description = "Python wrapper for the arXiv API";
    homepage = "https://github.com/lukasschwab/arxiv.py";
    changelog = "https://github.com/lukasschwab/arxiv.py/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.octvs ];
  };
}
