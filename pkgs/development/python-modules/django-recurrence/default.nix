{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  pdm-backend,
  pytest-cov-stub,
  pytest-django,
  pytestCheckHook,
  python-dateutil,
}:
buildPythonPackage (finalAttrs: {
  pname = "django-recurrence";
  version = "1.14";

  src = fetchFromGitHub {
    owner = "jazzband";
    repo = "django-recurrence";
    tag = finalAttrs.version;
    hash = "sha256-Hw9QebQuQfhooa6rhJ1+y7DTgPgaVF9kZzQ9H7NshmM=";
  };

  nativeCheckInputs = [
    pytest-django
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [
    pdm-backend
  ];

  dependencies = [
    django
    python-dateutil
  ];

  pyproject = true;
  pythonImportsCheck = [ "recurrence" ];

  meta = {
    description = "Utility for working with recurring dates in Django";
    homepage = "https://github.com/jazzband/django-recurrence";
    changelog = "https://github.com/jazzband/django-recurrence/blob/${finalAttrs.src.tag}/CHANGES.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ kurogeek ];
  };
})
