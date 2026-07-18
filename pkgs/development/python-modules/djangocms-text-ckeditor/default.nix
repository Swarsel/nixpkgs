{
  lib,
  buildPythonPackage,
  django-cms,
  fetchPypi,
  html5lib,
  pillow,
  pytest-django,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "djangocms-text-ckeditor";
  version = "5.1.7";

  src = fetchPypi {
    inherit version;
    hash = "sha256-xyl2TMXzyFaRGyBDku8fu++DE0G72cYv8AstPwcVnIM=";
    pname = "djangocms_text_ckeditor";
  };

  # Tests require module "djangocms-helper" which is not yet packaged
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    pytest-django
  ];

  preCheck = ''
    export DJANGO_SETTINGS_MODULE="tests.settings"
  '';

  build-system = [ setuptools ];

  dependencies = [
    django-cms
    html5lib
    pillow
  ];

  pyproject = true;
  pythonImportsCheck = [ "djangocms_text_ckeditor" ];

  meta = {
    description = "Text Plugin for django CMS using CKEditor 4";
    homepage = "https://github.com/django-cms/djangocms-text-ckeditor";
    changelog = "https://github.com/django-cms/djangocms-text-ckeditor/blob/${version}/CHANGELOG.rst";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.onny ];
  };
}
