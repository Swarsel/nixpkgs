{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  setuptools,
}:
buildPythonPackage (finalAttrs: {
  pname = "django-xforwardedfor-middleware";
  version = "2.0";

  src = fetchFromGitHub {
    owner = "allo-";
    repo = "django-xforwardedfor-middleware";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dDXSb17kXOSeIgY6wid1QFHhUjrapasWgCEb/El51eA=";
  };

  # No tests on upstream
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    django
  ];

  pyproject = true;
  pythonImportsCheck = [ "x_forwarded_for" ];

  meta = {
    description = "Use the X-Forwarded-For header to get the real ip of a request";
    homepage = "https://github.com/allo-/django-xforwardedfor-middleware";
    changelog = "https://github.com/allo-/django-xforwardedfor-middleware/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.publicDomain;
    maintainers = with lib.maintainers; [ kurogeek ];
  };
})
