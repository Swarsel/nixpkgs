{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  git,
  hatch-vcs,
  hatchling,
  icalendar,
  pygments,
  pytestCheckHook,
  python-dateutil,
  pytz,
  restructuredtext-lint,
  tzdata,
  x-wr-timezone,
}:

buildPythonPackage rec {
  pname = "recurring-ical-events";
  version = "3.9.0";

  src = fetchFromGitHub {
    owner = "niccokunzmann";
    repo = "python-recurring-ical-events";
    tag = "v${version}";
    hash = "sha256-hBZg1u6JtWGC+l1D1M18al6OQ298Z76tkiqYrBQYIzQ=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace 'dynamic = ["urls", "version"]' 'version = "${version}"'
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytz
    restructuredtext-lint
    pygments
  ];

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    icalendar
    python-dateutil
    tzdata
    x-wr-timezone
  ];

  pyproject = true;
  pythonImportsCheck = [ "recurring_ical_events" ];

  meta = {
    description = "Repeat ICalendar events by RRULE, RDATE and EXDATE";
    homepage = "https://github.com/niccokunzmann/python-recurring-ical-events";
    changelog = "https://github.com/niccokunzmann/python-recurring-ical-events/blob/${src.tag}/docs/changelog.md";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
