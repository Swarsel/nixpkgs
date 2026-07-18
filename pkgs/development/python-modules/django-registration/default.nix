{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  confusable-homoglyphs,
  coverage,
  django,
  pdm-backend,
}:

buildPythonPackage rec {
  pname = "django-registration";
  version = "5.2.1";

  src = fetchFromGitHub {
    owner = "ubernostrum";
    repo = "django-registration";
    tag = version;
    hash = "sha256-k7r4g+iCdAwAUNQdbtxzS5kqgAavEBAJERSWgXvbXqg=";
  };

  nativeCheckInputs = [
    coverage
    django
  ];

  installCheckPhase = ''
    runHook preInstallCheck

    DJANGO_SETTINGS_MODULE=tests.settings python -m coverage run --source django_registration runtests.py

    runHook postInstallCheck
  '';

  build-system = [ pdm-backend ];

  dependencies = [
    confusable-homoglyphs
  ];

  pyproject = true;
  pythonImportsCheck = [ "django_registration" ];

  meta = {
    description = "User registration app for Django";
    homepage = "https://django-registration.readthedocs.io/en/${version}/";
    changelog = "https://github.com/ubernostrum/django-registration/blob/${version}/docs/changelog.rst";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.l0b0 ];
    downloadPage = "https://github.com/ubernostrum/django-registration";
  };
}
