{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  celery,
  django,
  django-configurations,
  djangorestframework,
  factory-boy,
  freezegun,
  hatchling,
  joserfc,
  mozilla-django-oidc,
  nixosTests,
  pyjwt,
  pytest-django,
  pytestCheckHook,
  requests,
  requests-toolbelt,
  responses,
}:

buildPythonPackage rec {
  pname = "django-lasuite";
  version = "0.0.27";

  src = fetchFromGitHub {
    owner = "suitenumerique";
    repo = "django-lasuite";
    tag = "v${version}";
    hash = "sha256-bYV5/cPvmSU43oL7+9rCcISl0JqFPeK/xd22Kcg92II=";
  };

  nativeCheckInputs = [
    factory-boy
    freezegun
    pytestCheckHook
    pytest-django
    responses
  ]
  ++ lib.concatAttrValues optional-dependencies;

  preCheck = ''
    export PYTHONPATH=tests:$PYTHONPATH
    export DJANGO_SETTINGS_MODULE=test_project.settings
  '';

  build-system = [ hatchling ];

  dependencies = [
    django
    django-configurations
    djangorestframework
    joserfc
    mozilla-django-oidc
    pyjwt
    requests
    requests-toolbelt
  ];

  optional-dependencies = lib.fix (self: {
    all = with self; configuration ++ malware_detection;
    configuration = [ django-configurations ];
    malware_detection = [ celery ];
  });

  pyproject = true;
  pythonImportsCheck = [ "lasuite" ];
  pythonRelaxDeps = true;

  passthru.tests = {
    inherit (nixosTests)
      lasuite-docs
      lasuite-meet
      ;
  };

  meta = {
    description = "Common library for La Suite Django projects and Proconnected Django projects";
    homepage = "https://github.com/suitenumerique/django-lasuite";
    changelog = "https://github.com/suitenumerique/django-lasuite/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ soyouzpanda ];
    platforms = lib.platforms.linux;
  };
}
