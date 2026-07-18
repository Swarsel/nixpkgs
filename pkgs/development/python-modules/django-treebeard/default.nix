{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  pytest-django,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "django-treebeard";
  version = "4.8.0";

  src = fetchFromGitHub {
    owner = "django-treebeard";
    repo = "django-treebeard";
    tag = finalAttrs.version;
    hash = "sha256-DrjI0HlrJhNqrYul3SO0xkkFwjWRn94OgvTA/Z3wv84=";
  };

  nativeCheckInputs = [
    pytest-django
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ django ];
  pyproject = true;
  pythonImportsCheck = [ "treebeard" ];

  meta = {
    description = "Efficient tree implementations for Django";
    homepage = "https://tabo.pe/projects/django-treebeard/";
    changelog = "https://github.com/django-treebeard/django-treebeard/blob/${finalAttrs.src.tag}/CHANGES.md";
    license = lib.licenses.asl20;
  };
})
