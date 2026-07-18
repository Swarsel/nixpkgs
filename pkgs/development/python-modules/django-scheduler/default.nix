{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  icalendar,
  pytest-django,
  pytestCheckHook,
  python-dateutil,
  pytz,
  setuptools,
}:

buildPythonPackage rec {
  pname = "django-scheduler";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "llazzaro";
    repo = "django-scheduler";
    tag = "v${version}";
    hash = "sha256-TgIp2oqju3O6zPp3WMEB9HeNgAJILNkWWfbDFmMQ3eA=";
  };

  patches = [
    # Remove in Django 5.1
    # https://github.com/llazzaro/django-scheduler/pull/567
    ./index_together.patch
  ];

  postPatch = ''
    # Remove in Django 5.1
    substituteInPlace tests/settings.py \
      --replace-fail "SHA1PasswordHasher" "PBKDF2PasswordHasher"
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-django
  ];

  preCheck = ''
    export DJANGO_SETTINGS_MODULE=tests.settings
  '';

  build-system = [ setuptools ];

  dependencies = [
    django
    icalendar
    python-dateutil
    pytz
  ];

  disabledTests = lib.optionals (lib.versionAtLeast django.version "5.1") [
    # test_delete_event_authenticated_user - AssertionError: 302 != 200
    "test_delete_event_authenticated_user"
    "test_event_creation_authenticated_user"
  ];

  pyproject = true;
  pythonImportsCheck = [ "schedule" ];

  meta = {
    description = "Calendar app for Django";
    homepage = "https://github.com/llazzaro/django-scheduler";
    changelog = "https://github.com/llazzaro/django-scheduler/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ derdennisop ];
  };
}
