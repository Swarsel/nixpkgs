{
  lib,
  buildPythonPackage,
  django,
  fetchPypi,
  pillow,
  setuptools,
  six,
}:

let
  pname = "image";
  version = "1.5.33";
in
buildPythonPackage rec {
  inherit pname version;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-uqLgkXgnfapQ8i/W0dUex48ZwSaIkhy5q1gIdD8JcSY=";
  };

  build-system = [ setuptools ];

  dependencies = [
    pillow
    django
    six
  ];

  pyproject = true;
  pythonImportsCheck = [ "image" ];

  meta = {
    description = "Django application for image and video processing";
    homepage = "https://github.com/francescortiz/image";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ulysseszhan ];
  };
}
