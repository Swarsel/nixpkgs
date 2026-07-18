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
  xandikos,
}:

buildPythonPackage rec {
  pname = "caldav";
  version = "3.2.1";

  src = fetchFromGitHub {
    owner = "python-caldav";
    repo = "caldav";
    tag = "v${version}";
    hash = "sha256-SCqc0MVxKaHpES+NkDcaItHlkk0kCFj6kFqH8k08vdA=";
  };

  nativeCheckInputs = [
    manuel
    proxy-py
    pyfakefs
    pytest-asyncio
    pytestCheckHook
    (toPythonModule (radicale.override { python3 = python; }))
    tzlocal
    vobject
    writableTmpDirAsHomeHook
    (toPythonModule (xandikos.override { python3Packages = python.pkgs; }))
  ];

  __darwinAllowLocalNetworking = true;

  build-system = [
    hatchling
    hatch-vcs
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

  pyproject = true;
  pythonImportsCheck = [ "caldav" ];

  meta = {
    description = "CalDAV (RFC4791) client library";
    homepage = "https://github.com/python-caldav/caldav";
    changelog = "https://github.com/python-caldav/caldav/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      marenz
      dotlambda
    ];
  };
}
