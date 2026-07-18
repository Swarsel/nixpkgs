{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  setuptools,
}:
buildPythonPackage (finalAttrs: {
  pname = "django-error-report-2";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "matmair";
    repo = "django-error-report-2";
    tag = finalAttrs.version;
    hash = "sha256-ZCaslqgruJxM8345/jSlZGruM+27H9hvwL0wtPkUzc0=";
  };

  # There are no tests on upstream
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    django
  ];

  pyproject = true;
  pythonImportsCheck = [ "error_report" ];

  meta = {
    description = "Log/View Django server errors";
    homepage = "https://github.com/matmair/django-error-report-2";
    changelog = "https://github.com/matmair/django-error-report-2/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kurogeek ];
  };
})
