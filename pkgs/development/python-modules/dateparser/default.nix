{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  convertdate,
  fasttext,
  gitpython,
  hijridate,
  langdetect,
  numpy,
  parameterized,
  parsel,
  pytestCheckHook,
  python-dateutil,
  pytz,
  regex,
  requests,
  ruamel-yaml,
  setuptools,
  tzlocal,
}:

buildPythonPackage rec {
  pname = "dateparser";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "scrapinghub";
    repo = "dateparser";
    tag = "v${version}";
    hash = "sha256-TA4GZb24++RF1sw4tECJF5UzouRCwwhPiim5z5/hMzU=";
  };

  nativeCheckInputs = [
    parameterized
    pytestCheckHook
    gitpython
    parsel
    requests
    ruamel-yaml
  ]
  ++ lib.concatAttrValues optional-dependencies;

  preCheck = ''
    export HOME="$TEMPDIR"
  '';

  build-system = [ setuptools ];

  dependencies = [
    python-dateutil
    pytz
    regex
    tzlocal
  ];

  disabledTests = [
    # access network
    "test_custom_language_detect_fast_text_0"
    "test_custom_language_detect_fast_text_1"
  ];

  # Upstream only runs the tests in tests/ in CI, others use git clone
  enabledTestPaths = [ "tests" ];

  optional-dependencies = {
    calendars = [
      hijridate
      convertdate
    ];

    fasttext = [
      fasttext
      numpy
    ];

    langdetect = [ langdetect ];
  };

  pyproject = true;
  pythonImportsCheck = [ "dateparser" ];

  meta = {
    description = "Date parsing library designed to parse dates from HTML pages";
    homepage = "https://github.com/scrapinghub/dateparser";
    changelog = "https://github.com/scrapinghub/dateparser/blob/${src.tag}/HISTORY.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "dateparser-download";
  };
}
