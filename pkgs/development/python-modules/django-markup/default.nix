{
  lib,
  fetchFromGitHub,
  # optionals
  bleach,
  buildPythonPackage,
  # dependencies
  django,
  docutils,
  markdown,
  # build-system
  poetry-core,
  pygments,
  # tests
  pytest-cov-stub,
  pytest-django,
  pytestCheckHook,
  python-creole,
  smartypants,
  textile,
}:

buildPythonPackage rec {
  pname = "django-markup";
  version = "1.10";

  src = fetchFromGitHub {
    owner = "bartTC";
    repo = "django-markup";
    tag = "v${version}";
    hash = "sha256-LcEbN5/LbY3xWellBVK2Kfvt/XLzRJjGWcEk8h722Og=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytest-django
    pytestCheckHook
  ]
  ++ optional-dependencies.all_filter_dependencies;

  preCheck = ''
    export DJANGO_SETTINGS_MODULE=django_markup.tests
  '';

  build-system = [ poetry-core ];
  dependencies = [ django ];

  disabledTests = [
    # pygments compat issue
    "test_rst_with_pygments"
  ];

  optional-dependencies = {
    all_filter_dependencies = [
      bleach
      docutils
      markdown
      pygments
      python-creole
      smartypants
      textile
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "django_markup" ];

  meta = {
    description = "Generic Django application to convert text with specific markup to html";
    homepage = "https://github.com/bartTC/django-markup";
    changelog = "https://github.com/bartTC/django-markup/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
