{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  icalendar,
  poetry-core,
  pook,
  pytestCheckHook,
  python-dateutil,
  pytz,
  urllib3,
}:

buildPythonPackage rec {
  pname = "icalevents";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "jazzband";
    repo = "icalevents";
    tag = version;
    hash = "sha256-QDqmcZY/UANVKRjk1ZFEFHgrjtD+hXE4qd3tX64sE7c=";
  };

  nativeCheckInputs = [
    pook
    pytestCheckHook
  ];

  build-system = [
    poetry-core
  ];

  dependencies = [
    icalendar
    python-dateutil
    pytz
    urllib3
  ];

  disabledTests = [
    # Makes HTTP calls
    "test_events_url"
    "test_events_async_url"
  ];

  pyproject = true;
  pythonImportsCheck = [ "icalevents" ];

  meta = {
    description = "Python module for iCal URL/file parsing and querying";
    homepage = "https://github.com/jazzband/icalevents";
    changelog = "https://github.com/jazzband/icalevents/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jamiemagee ];
  };
}
