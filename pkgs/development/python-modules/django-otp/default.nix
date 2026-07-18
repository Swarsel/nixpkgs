{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  freezegun,
  hatchling,
  pytest,
  python,
  qrcode,
}:

buildPythonPackage rec {
  pname = "django-otp";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "django-otp";
    repo = "django-otp";
    tag = "v${version}";
    hash = "sha256-Tqi6FHXJToOJsGETgIRl8rOUTfkn3kBkG5/bI8CxT24=";
  };

  env.DJANGO_SETTINGS_MODUOLE = "test.test_project.settings";

  nativeCheckInputs = [
    freezegun
    pytest
  ];

  checkPhase = ''
    runHook preCheck

    export PYTHONPATH=$PYTHONPATH:test
    export DJANGO_SETTINGS_MODULE=test_project.settings
    ${python.interpreter} -m django test django_otp

    runHook postCheck
  '';

  build-system = [ hatchling ];

  dependencies = [
    django
    qrcode
  ];

  enabledTestPaths = [ "src/django_otp/test.py" ];
  pyproject = true;
  pythonImportsCheck = [ "django_otp" ];

  meta = {
    description = "Pluggable framework for adding two-factor authentication to Django using one-time passwords";
    homepage = "https://github.com/django-otp/django-otp";
    changelog = "https://github.com/django-otp/django-otp/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
}
