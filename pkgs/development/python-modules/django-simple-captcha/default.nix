{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  django,
  django-ranged-response,
  # tests
  flite,
  pillow,
  pytest-django,
  pytestCheckHook,
  # build-system
  setuptools,
  testfixtures,
}:

buildPythonPackage rec {
  pname = "django-simple-captcha";
  version = "0.6.3";

  src = fetchFromGitHub {
    owner = "mbi";
    repo = "django-simple-captcha";
    tag = "v${version}";
    hash = "sha256-Fee7YfIWGyKMsN7XQz10bjIhbjUYRuY7Oe4Q8n8ILz0=";
  };

  nativeCheckInputs = [
    flite
    pytest-django
    pytestCheckHook
    testfixtures
  ];

  checkPhase = ''
    runHook preCheck
    pushd testproject
    python manage.py test captcha
    popd
    runHook postCheck
  '';

  build-system = [ setuptools ];

  dependencies = [
    django
    pillow
    django-ranged-response
  ];

  pyproject = true;

  meta = {
    description = "Customizable Django application to add captcha images to any Django form";
    homepage = "https://github.com/mbi/django-simple-captcha";
    changelog = "https://github.com/mbi/django-simple-captcha/blob/${src.tag}/CHANGES";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      mrmebelman
    ];
  };
}
