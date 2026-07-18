{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  # build-system
  hatchling,
  # dependencies
  lxml,
  lxml-html-clean,
  # tests
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "html-sanitizer";
  version = "2.6";

  src = fetchFromGitHub {
    owner = "matthiask";
    repo = "html-sanitizer";
    tag = version;
    hash = "sha256-egBGhv7vudH32jwh9rAXuXfMzPDxJ60S5WKbc4kzCTU=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];

  dependencies = [
    lxml
    lxml-html-clean
    beautifulsoup4
  ];

  disabledTests = [
    # Tests are sensitive to output
    "test_billion_laughs"
    "test_10_broken_html"
  ];

  enabledTestPaths = [ "html_sanitizer/tests.py" ];
  pyproject = true;
  pythonImportsCheck = [ "html_sanitizer" ];

  meta = {
    description = "Allowlist-based and very opinionated HTML sanitizer";
    homepage = "https://github.com/matthiask/html-sanitizer";
    changelog = "https://github.com/matthiask/html-sanitizer/blob/${version}/CHANGELOG.rst";
    license = with lib.licenses; [ bsd3 ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
