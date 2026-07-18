{
  lib,
  buildPythonPackage,
  django,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "django-colorful";
  version = "1.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-/SRvL7KX7QdNxDSZZtM6HILQMIt/sNbvbi52uQzv/7c=";
  };

  buildInputs = [ django ];
  # Tests aren't run
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "colorful" ];

  meta = {
    description = "Django extension that provides database and form color fields";
    homepage = "https://github.com/charettes/django-colorful";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
