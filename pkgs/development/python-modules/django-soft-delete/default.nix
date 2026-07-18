{
  lib,
  buildPythonPackage,
  django,
  fetchPypi,
  hatchling,
}:

buildPythonPackage rec {
  pname = "django-soft-delete";
  version = "1.0.23";

  src = fetchPypi {
    inherit version;
    hash = "sha256-gUZZ8NGdTyr8WLMf9z+I8K9mcVzO87T82PazoBHVmyo=";
    pname = "django_soft_delete";
  };

  # No tests
  doCheck = false;
  build-system = [ hatchling ];
  dependencies = [ django ];
  pyproject = true;
  pythonImportsCheck = [ "django_softdelete" ];

  meta = {
    description = "Soft delete models, managers, queryset for Django";
    homepage = "https://github.com/san4ezy/django_softdelete";
    changelog = "https://github.com/san4ezy/django_softdelete/blob/master/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
