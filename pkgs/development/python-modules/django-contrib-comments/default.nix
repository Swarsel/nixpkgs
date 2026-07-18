{
  lib,
  buildPythonPackage,
  django,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "django-contrib-comments";
  version = "2.2.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-SN4A8VZ34BaiFq7/IF1uAOQ5HJpXAhNsZBGcRytzVto=";
  };

  propagatedBuildInputs = [ django ];
  format = "setuptools";

  meta = {
    description = "Code formerly known as django.contrib.comments";
    homepage = "https://github.com/django/django-contrib-comments";
    license = lib.licenses.bsd0;
  };
}
