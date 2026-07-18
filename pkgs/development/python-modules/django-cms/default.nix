{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dj-database-url,
  django,
  django-classy-tags,
  django-cms,
  django-formtools,
  django-sekizai,
  django-treebeard,
  djangocms-admin-style,
  djangocms-text-ckeditor,
  fetchpatch,
  gettext,
  iptools,
  python,
  setuptools,
}:

buildPythonPackage rec {
  pname = "django-cms";
  version = "5.0.6";

  src = fetchFromGitHub {
    owner = "django-cms";
    repo = "django-cms";
    tag = version;
    hash = "sha256-pYxIW/GGBIKzsQs2QJiRkScDPzSf3YXC+HkDsfAgg/w=";
  };

  # Tests depend on djangocms-text-ckeditor and djangocms-admin-style,
  # which depends on this package.
  # To avoid infinite recursion, we only enable tests when building passthru.tests.
  doCheck = false;
  nativeCheckInputs = [ gettext ];

  checkInputs = [
    dj-database-url
    djangocms-text-ckeditor
    iptools
  ];

  preCheck = ''
    # Disable ruff formatter test
    rm cms/tests/test_static_analysis.py
  '';

  checkPhase = ''
    runHook preCheck
    ${python.interpreter} manage.py test
    runHook postCheck
  '';

  build-system = [ setuptools ];

  dependencies = [
    django
    django-classy-tags
    django-formtools
    django-treebeard
    django-sekizai
    djangocms-admin-style
  ];

  pyproject = true;
  pythonImportsCheck = [ "cms" ];

  passthru.tests = {
    runTests = django-cms.overridePythonAttrs (_: {
      doCheck = true;
    });
  };

  meta = {
    description = "Lean enterprise content management powered by Django";
    homepage = "https://django-cms.org";
    changelog = "https://github.com/django-cms/django-cms/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.onny ];
  };
}
