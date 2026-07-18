{
  lib,
  boto3,
  buildPythonPackage,
  celery,
  django,
  django-colorful,
  fetchPypi,
  importlib-metadata,
  isPy3k,
  numpy,
  pillow,
  psycopg2,
  pyparsing,
}:

buildPythonPackage rec {
  pname = "django-raster";
  version = "0.8.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "213758fe96d74be502f69f2620f7666961a85caa0551d14573637315035a9745";
  };

  propagatedBuildInputs = [
    numpy
    django-colorful
    pillow
    psycopg2
    pyparsing
    django
    celery
    boto3
    importlib-metadata
  ];

  # Tests require a postgresql + postgis server
  doCheck = false;
  disabled = !isPy3k;
  format = "setuptools";

  meta = {
    description = "Basic raster data integration for Django";
    homepage = "https://github.com/geodesign/django-raster";
    license = lib.licenses.mit;
  };
}
