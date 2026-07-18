{
  lib,
  fetchFromGitHub,
  arrow,
  attrs,
  buildPythonPackage,
  pytest-flakes,
  pytestCheckHook,
  setuptools,
  tatsu,
}:

buildPythonPackage rec {
  pname = "ics";
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "ics-py";
    repo = "ics-py";
    tag = "v${version}";
    hash = "sha256-hdtnET7YfSb85+TGwpwzoxOfxPT7VSj9eKSiV6AXUS8=";
  };

  postPatch = ''
    substituteInPlace setup.cfg \
      --replace-fail "--pep8" ""
  '';

  nativeCheckInputs = [
    pytest-flakes
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    attrs
    arrow
    tatsu
  ];

  disabledTests = [
    # Failure seems to be related to arrow > 1.0
    "test_event"
    # Broke with TatSu 5.7:
    "test_many_lines"
    # AssertionError: 'Europe/Berlin' not found in "tzfile('Atlantic/Jan_Mayen')"
    "test_timezone_not_dropped"
    # tatsu PEG parser hits recursion limit on the bundled gehol/BA1.ics fixture
    "test_gehol"
  ];

  pyproject = true;
  pythonImportsCheck = [ "ics" ];

  meta = {
    description = "Pythonic and easy iCalendar library (RFC 5545)";

    longDescription = ''
      Ics.py is a pythonic and easy iCalendar library. Its goals are to read and
      write ics data in a developer friendly way.
    '';

    homepage = "http://icspy.readthedocs.org/";
    changelog = "https://github.com/ics-py/ics-py/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
