{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "django-model-utils";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "jazzband";
    repo = "django-model-utils";
    tag = version;
    hash = "sha256-iRtTYXsgD8NYG3k9ZWAr2Nwazo3HUa6RgdbMeDxc7NI=";
  };

  # Test requires postgres database
  doCheck = false;
  build-system = [ setuptools-scm ];
  dependencies = [ django ];
  pyproject = true;
  pythonImportsCheck = [ "model_utils" ];

  meta = {
    description = "Django model mixins and utilities";
    homepage = "https://github.com/jazzband/django-model-utils";
    changelog = "https://github.com/jazzband/django-model-utils/blob/${version}/CHANGES.rst";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
