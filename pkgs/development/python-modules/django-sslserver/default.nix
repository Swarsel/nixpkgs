{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  setuptools-scm,
}:
buildPythonPackage (finalAttrs: {
  pname = "django-sslserver";
  version = "0.15";

  src = fetchFromGitHub {
    owner = "teddziuba";
    repo = "django-sslserver";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RIhqvwJQ7fYZT1SAkbcBNl2jX7j7UZND8e5Vra+ibHA=";
  };

  # No tests on upstream
  doCheck = false;
  build-system = [ setuptools-scm ];

  dependencies = [
    django
  ];

  pyproject = true;
  pythonImportsCheck = [ "sslserver" ];

  meta = {
    description = "SSL-enabled development server for Django";
    homepage = "https://github.com/teddziuba/django-sslserver";
    changelog = "https://github.com/teddziuba/django-sslserver/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kurogeek ];
  };
})
