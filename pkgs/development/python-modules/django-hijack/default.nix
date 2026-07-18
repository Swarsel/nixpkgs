{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  django,
  # build-system
  flit-gettext,
  flit-scm,
  nix-update-script,
  # tests
  pytest-cov-stub,
  pytest-django,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "django-hijack";
  version = "3.7.8";

  src = fetchFromGitHub {
    owner = "django-hijack";
    repo = "django-hijack";
    tag = version;
    hash = "sha256-91ziHv39GmXrbswqOyVHmSv11LqKNT318/8mx5iIdHg=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    pytest-django
  ];

  preCheck = ''
    export DJANGO_SETTINGS_MODULE=tests.test_app.settings
  '';

  build-system = [
    flit-gettext
    flit-scm
  ];

  dependencies = [ django ];
  pyproject = true;
  # needed for npmDeps update
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Allows superusers to hijack (=login as) and work on behalf of another user";
    homepage = "https://github.com/django-hijack/django-hijack";
    changelog = "https://github.com/django-hijack/django-hijack/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ris ];
  };
}
