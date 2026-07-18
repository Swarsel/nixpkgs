{
  lib,
  buildPythonPackage,
  changelog-chug,
  docutils,
  fetchPypi,
  lockfile,
  packaging,
  pytestCheckHook,
  setuptools,
  testscenarios,
  testtools,
}:

buildPythonPackage rec {
  pname = "python-daemon";
  version = "3.1.2";

  src = fetchPypi {
    inherit version;
    hash = "sha256-97BDNa3Ec96Hf1EX4m1fEUL0yffNdlQI8Id3V75a+/Q=";
    pname = "python_daemon";
  };

  nativeCheckInputs = [
    pytestCheckHook
    testscenarios
    testtools
  ];

  build-system = [
    changelog-chug
    setuptools
    packaging
  ];

  dependencies = [
    docutils
    lockfile
  ];

  disabledTests = [
    "begin_with_TestCase"
    "changelog_TestCase"
    "ChangeLogEntry"
    "DaemonContext"
    "file_descriptor"
    "get_distribution_version_info_TestCase"
    "InvalidFormatError_TestCase"
    "make_year_range_TestCase"
    "ModuleExceptions_TestCase"
    "test_metaclass_not_called"
    "test_passes_specified_object"
    "test_returns_expected"
    "value_TestCase"
    "YearRange_TestCase"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "daemon"
    "daemon.daemon"
    "daemon.pidfile"
  ];

  meta = {
    description = "Library to implement a well-behaved Unix daemon process";
    homepage = "https://pagure.io/python-daemon/";

    # See "Copying" section in https://pagure.io/python-daemon/blob/main/f/README
    license = with lib.licenses; [
      gpl3Plus
      asl20
    ];

    maintainers = [ ];
  };
}
