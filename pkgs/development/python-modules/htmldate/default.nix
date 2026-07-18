{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  charset-normalizer,
  dateparser,
  faust-cchardet,
  lxml,
  pytestCheckHook,
  python-dateutil,
  setuptools,
  urllib3,
}:

buildPythonPackage rec {
  pname = "htmldate";
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "adbar";
    repo = "htmldate";
    tag = "v${version}";
    hash = "sha256-3qtksgzqcgWtUv81Aqeh0nTWYnH0PjPLG4NuYChbV0g=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    charset-normalizer
    dateparser
    lxml
    python-dateutil
    urllib3
  ];

  disabledTests = [
    # Tests that require an internet connection
    "test_input"
    "test_cli"
    "test_download"
    "test_readme_examples"
  ];

  optional-dependencies = {
    all = [
      faust-cchardet
      urllib3
    ]
    ++ urllib3.optional-dependencies.brotli;

    speed = [
      faust-cchardet
      urllib3
    ]
    ++ urllib3.optional-dependencies.brotli;
  };

  pyproject = true;
  pythonImportsCheck = [ "htmldate" ];
  pythonRelaxDeps = [ "lxml" ];

  meta = {
    description = "Module for the extraction of original and updated publication dates from URLs and web pages";
    homepage = "https://htmldate.readthedocs.io";
    changelog = "https://github.com/adbar/htmldate/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jokatzke ];
    mainProgram = "htmldate";
  };
}
