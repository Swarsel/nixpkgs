{
  lib,
  fetchFromGitHub,
  bleach,
  buildPythonPackage,
  django,
  markdown,
  pytest-django,
  pytestCheckHook,
  setuptools,
  tinycss2,
}:
buildPythonPackage (finalAttrs: {
  pname = "django-markdownify";
  version = "0.9.7";

  src = fetchFromGitHub {
    owner = "erwinmatijsen";
    repo = "django-markdownify";
    tag = finalAttrs.version;
    hash = "sha256-Zl6t/ja/VAYrVOM6xkjcayn+vCss6JLQr+vBGsGGp+k=";
  };

  nativeCheckInputs = [
    tinycss2
    pytest-django
    pytestCheckHook
  ];

  preCheck = ''
    export DJANGO_SETTINGS_MODULE=markdownify.checks
  '';

  build-system = [ setuptools ];

  dependencies = [
    django
    markdown
    bleach
  ]
  ++ bleach.optional-dependencies.css;

  disabledTests = [
    # Test settings didn't setup DjangoTemplates
    "test_markdownify_nodelist"
  ];

  pyproject = true;
  pythonImportsCheck = [ "markdownify" ];

  meta = {
    description = "Markdown template filter for Django";
    homepage = "https://github.com/erwinmatijsen/django-markdownify";
    changelog = "https://github.com/erwinmatijsen/django-markdownify/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kurogeek ];
  };
})
