{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "django-gravatar2";
  version = "1.4.5";

  src = fetchPypi {
    inherit version;
    hash = "sha256-LbtWRl45Xdizkg1AF+J6R1aRLMKtmxG6SM8UOHGoA2Q=";
    pname = "django_gravatar2";
  };

  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "django_gravatar" ];

  meta = {
    description = "Essential Gravatar support for Django";
    homepage = "https://github.com/twaddington/django-gravatar";
    license = lib.licenses.mit;
  };
}
