{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  distutils,
  django,
  django-app-helper,
  django-cms,
  django-parler,
  pytest-django,
  pytestCheckHook,
  python,
  setuptools,
}:

buildPythonPackage rec {
  pname = "djangocms-alias";
  version = "3.1.1";

  src = fetchFromGitHub {
    owner = "django-cms";
    repo = "djangocms-alias";
    tag = version;
    hash = "sha256-mZvOM27wmcHdem3GfnBZpzx+1hwrX3IeEr8K8M5LrrU=";
  };

  # Disable tests because dependency djangocms-versioning isn't packaged yet.
  doCheck = false;

  checkInputs = [
    beautifulsoup4
    distutils
    django-app-helper
    pytestCheckHook
    pytest-django
  ];

  checkPhase = ''
    runHook preCheck
    ${python.interpreter} test_settings.py
    runHook postCheck
  '';

  build-system = [ setuptools ];

  dependencies = [
    django
    django-cms
    django-parler
  ];

  pyproject = true;
  pythonImportsCheck = [ "djangocms_alias" ];

  meta = {
    description = "Lean enterprise content management powered by Django";
    homepage = "https://django-cms.org";
    changelog = "https://github.com/django-cms/djangocms-alias/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.onny ];
  };
}
