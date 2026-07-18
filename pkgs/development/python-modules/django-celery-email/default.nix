{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  celery,
  django,
  django-appconf,
  pytest-django,
  pytestCheckHook,
  python,
}:

buildPythonPackage rec {
  pname = "django-celery-email";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "pmclanahan";
    repo = "django-celery-email";
    rev = version;
    hash = "sha256-LBavz5Nh2ObmIwLCem8nHvsuKgPwkzbS/OzFPmSje/M=";
  };

  propagatedBuildInputs = [
    django
    django-appconf
    celery
  ];

  env.DJANGO_SETTINGS_MODULE = "tests.settings";

  nativeCheckInputs = [
    pytest-django
    pytestCheckHook
  ];

  checkPhase = ''
    ${python.executable} runtests.py
  '';

  format = "setuptools";
  pythonImportsCheck = [ "djcelery_email" ];

  meta = {
    description = "Django email backend that uses a celery task for sending the email";
    homepage = "https://github.com/pmclanahan/django-celery-email";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ onny ];
  };
}
