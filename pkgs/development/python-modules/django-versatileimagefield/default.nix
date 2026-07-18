{
  lib,
  buildPythonPackage,
  django,
  fetchPypi,
  pillow,
  python-magic,
}:

buildPythonPackage rec {
  pname = "django-versatileimagefield";
  version = "3.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-M5DiAEgJjol78pmwNgdj0QzQiWZbeu+OupAO7Lrq0Ng=";
  };

  propagatedBuildInputs = [
    pillow
    python-magic
  ];

  # tests not included with pypi release
  doCheck = false;
  nativeCheckInputs = [ django ];
  format = "setuptools";
  pythonImportsCheck = [ "versatileimagefield" ];

  meta = {
    description = "Replaces django's ImageField with a more flexible interface";
    homepage = "https://github.com/respondcreate/django-versatileimagefield/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
