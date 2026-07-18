{
  lib,
  fetchFromGitHub,
  # dependencies
  asgiref,
  buildPythonPackage,
  django,
  minify-html,
  # tests
  pytest-django,
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "django-minify-html";
  version = "1.14.0";

  src = fetchFromGitHub {
    owner = "adamchainz";
    repo = "django-minify-html";
    tag = version;
    hash = "sha256-mTFHIZo1E9+d7bOfelFCUZRt5eEo6w+xKB5qf9jc8hY=";
  };

  nativeCheckInputs = [
    pytest-django
    pytestCheckHook
  ];

  preCheck = ''
    export DJANGO_SETTINGS_MODULE=tests.settings
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    asgiref
    django
    minify-html
  ];

  pyproject = true;

  pythonImportsCheck = [
    "django_minify_html"
  ];

  meta = {
    description = "Use minify-html, the extremely fast HTML + JS + CSS minifier, with Django";
    homepage = "https://github.com/adamchainz/django-minify-html";
    changelog = "https://github.com/adamchainz/django-minify-html/blob/${src.rev}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
