{
  lib,
  buildPythonPackage,
  django,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "django-environ";
  version = "0.12.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-In3IkUU91b3nacNEnPSnS28u6PerI2HJOgcGj0F5BBo=";
    pname = "django_environ";
  };

  buildInputs = [ django ];
  # The testsuite fails to modify the base environment
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "environ" ];

  meta = {
    description = "Utilize environment variables to configure your Django application";
    homepage = "https://github.com/joke2k/django-environ/";
    changelog = "https://github.com/joke2k/django-environ/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
