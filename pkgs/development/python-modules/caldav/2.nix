{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dnspython,
  hatch-vcs,
  hatchling,
  icalendar,
  icalendar-searcher,
  lxml,
  manuel,
  niquests,
  proxy-py,
  pyfakefs,
  pytest-asyncio,
  pytestCheckHook,
  python,
  python-dateutil,
  pyyaml,
  radicale,
  recurring-ical-events,
  toPythonModule,
  tzlocal,
  vobject,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "caldav";
  version = "2.2.6";

  src = fetchFromGitHub {
    owner = "python-caldav";
    repo = "caldav";
    tag = "v${version}";
    hash = "sha256-xtxWDlYESIwkow/YdjaUAkJ/x2jdUyhqfSRycJVLncY=";
  };

  nativeCheckInputs = [
    manuel
    proxy-py
    pyfakefs
    pytestCheckHook
    (toPythonModule (radicale.override { python3 = python; }))
    tzlocal
    vobject
    writableTmpDirAsHomeHook
  ];

  __darwinAllowLocalNetworking = true;

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    dnspython
    lxml
    niquests
    icalendar
    icalendar-searcher
    recurring-ical-events
    python-dateutil
    pyyaml
  ];

  disabledTests = [
    # test contacts CalDAV servers on the internet
    "test_rfc8764_test_conf"
    # succeeds with Xandikos but fails with Radicale
    "testConfigfile"
  ];

  pyproject = true;
  pythonImportsCheck = [ "caldav" ];

  meta = {
    description = "CalDAV (RFC4791) client library";
    homepage = "https://github.com/python-caldav/caldav";
    changelog = "https://github.com/python-caldav/caldav/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
