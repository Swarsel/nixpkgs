{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  django-recurrence,
  icalendar,
  pytest-django,
  pytestCheckHook,
  setuptools-scm,
}:
buildPythonPackage (finalAttrs: {
  pname = "django-ical";
  version = "1.9.2";

  src = fetchFromGitHub {
    owner = "jazzband";
    repo = "django-ical";
    tag = finalAttrs.version;
    hash = "sha256-DUe0loayGcUS7MTyLn+g0KBxbIY7VsaoQNHGSMbMI3U=";
  };

  nativeCheckInputs = [
    pytest-django
    pytestCheckHook
  ];

  preCheck = ''
    export DJANGO_SETTINGS_MODULE=test_settings
  '';

  build-system = [ setuptools-scm ];

  dependencies = [
    django
    django-recurrence
    icalendar
  ];

  disabledTestPaths = [
    # AssertionError: 'Japan' != 'JST': there seems to be wrong raw data feed
    "django_ical/tests/test_feed.py::ICal20FeedTest::test_timezone"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "django_ical"
  ];

  meta = {
    description = "iCal feeds for Django based on Django's syndication feed framework";
    homepage = "https://github.com/jazzband/django-ical";
    changelog = "https://github.com/jazzband/django-ical/blob/${finalAttrs.src.tag}/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kurogeek ];
  };
})
