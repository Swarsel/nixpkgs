{
  lib,
  fetchFromGitHub,
  boto3,
  buildPythonPackage,
  cryptography,
  django,
  hatchling,
  idna,
  mock,
  pytest-django,
  pytestCheckHook,
  requests,
  responses,
  urllib3,
}:

buildPythonPackage rec {
  pname = "django-anymail";
  version = "15.0";

  src = fetchFromGitHub {
    owner = "anymail";
    repo = "django-anymail";
    tag = "v${version}";
    hash = "sha256-SAiHjVFh0x1lXoxAlU+Lpfzv9pndsz/V9AVWwyKehEo=";
  };

  nativeCheckInputs = [
    mock
    responses
    pytest-django
    pytestCheckHook
  ]
  ++ optional-dependencies.amazon-ses;

  preCheck = ''
    export CONTINOUS_INTEGRATION=1
    export DJANGO_SETTINGS_MODULE=tests.test_settings.settings_${lib.versions.major django.version}_0
  '';

  build-system = [ hatchling ];

  dependencies = [
    django
    idna
    requests
    urllib3
  ];

  disabledTestMarks = [ "live" ];

  disabledTestPaths = [
    # likely guessed mime type mismatch
    "tests/test_resend_backend.py::ResendBackendStandardEmailTests::test_attachments"
  ];

  disabledTests = [
    # misrecognized as a fixture due to function name starting with test_
    "test_file_content"
  ];

  optional-dependencies = {
    amazon-ses = [ boto3 ];
    postal = [ cryptography ];
    sendgrid = [ cryptography ];
    # not packaged
    # resend = [ svix ];
    # uts46 = [ uts46 ];
  };

  pyproject = true;
  pythonImportsCheck = [ "anymail" ];

  meta = {
    description = "Django email backends and webhooks for Mailgun";
    homepage = "https://github.com/anymail/django-anymail";
    changelog = "https://github.com/anymail/django-anymail/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ onny ];
  };
}
