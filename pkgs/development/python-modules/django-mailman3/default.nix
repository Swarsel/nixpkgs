{
  lib,
  buildPythonPackage,
  # tests
  django,
  django-allauth,
  # dependencies
  django-gravatar2,
  fetchPypi,
  fetchpatch,
  mailmanclient,
  nixosTests,
  # build-system
  pdm-backend,
  pytest-django,
  pytestCheckHook,
  pytz,
}:

buildPythonPackage rec {
  pname = "django-mailman3";
  version = "1.3.15";

  src = fetchPypi {
    inherit version;
    hash = "sha256-+ZFrJpy5xdW6Yde/XEvxoAN8+TSQdiI0PfjZ7bHG0Rs=";
    pname = "django_mailman3";
  };

  patches = [
    (fetchpatch {
      excludes = [
        ".gitlab-ci.yml"
        "README.rst"
      ];

      hash = "sha256-gSFczuNLlMclqixOu6ElS0BewUTGyhP6RXtE/waLzyo=";
      name = "django-5.2.patch";
      url = "https://gitlab.com/mailman/django-mailman3/-/commit/465c1ffc77556bb8a80a678f53a40f16b9766cc6.patch";
    })

    (fetchpatch {
      hash = "sha256-xgQu70DkbPz+ULRFgKeJTbx/Tq2PLEyGgrncf26ChA4=";
      # Only needed so the next one applies.
      name = "allauth-64-1.patch";
      url = "https://gitlab.com/mailman/django-mailman3/-/commit/96f3f3bf0c718395ccd1b0d539a40d627522a9c4.patch";
    })
    (fetchpatch {
      hash = "sha256-6mwGSw31Q0+APwdGFe0JE0gBigdo453HZZ6JApqgtTE=";
      name = "allauth-64-2.patch";
      url = "https://gitlab.com/mailman/django-mailman3/-/commit/cfdacb9195ce266e5ae23307b31304898369f696.patch";
    })
  ];

  nativeCheckInputs = [
    django
    pytest-django
    pytestCheckHook
  ];

  preCheck = ''
    export DJANGO_SETTINGS_MODULE=django_mailman3.tests.settings_test
  '';

  build-system = [ pdm-backend ];

  dependencies = [
    django-allauth
    django-gravatar2
    mailmanclient
    pytz
  ]
  ++ django-allauth.optional-dependencies.openid
  ++ django-allauth.optional-dependencies.socialaccount;

  pyproject = true;
  pythonImportsCheck = [ "django_mailman3" ];
  pythonRelaxDeps = [ "django-allauth" ];

  passthru.tests = {
    inherit (nixosTests) mailman;
  };

  meta = {
    description = "Django library for Mailman UIs";
    homepage = "https://gitlab.com/mailman/django-mailman3";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ qyliss ];
    broken = lib.versionAtLeast django.version "5.3";
  };
}
