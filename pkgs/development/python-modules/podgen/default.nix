{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dateutils,
  future,
  lxml,
  pytest-mock,
  pytestCheckHook,
  python-dateutil,
  pytz,
  requests,
  setuptools,
  tinytag,
}:

buildPythonPackage rec {
  pname = "podgen";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "tobinus";
    repo = "python-podgen";
    tag = "v${version}";
    hash = "sha256-IlTbKWNdEHJmEPdslKphZLB5IVERxNL/wqCMbJDHkD4=";
  };

  nativeCheckInputs = [
    pytest-mock
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    dateutils
    future
    lxml
    python-dateutil
    pytz
    requests
    tinytag
  ];

  disabledTestPaths = [
    # test requires downloading content
    "podgen/tests/test_media.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "podgen" ];

  meta = {
    description = "Python module to generate Podcast feeds";
    homepage = "https://podgen.readthedocs.io/en/latest/";
    changelog = "https://github.com/tobinus/python-podgen/blob/v${version}/CHANGELOG.md";

    license = with lib.licenses; [
      bsd2
      lgpl3
    ];

    maintainers = with lib.maintainers; [ ethancedwards8 ];
    downloadPage = "https://github.com/tobinus/python-podgen";
  };
}
