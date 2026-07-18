{
  lib,
  buildPythonPackage,
  django-classy-tags,
  fetchPypi,
  pytest-django,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "django-sekizai";
  version = "4.1.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Kso2y64LXAzv7ZVlQW7EQjNXZ/sxRb/xHlhiL8ZTza0=";
  };

  propagatedBuildInputs = [ django-classy-tags ];
  env.DJANGO_SETTINGS_MODULE = "tests.settings";

  checkInputs = [
    pytestCheckHook
    pytest-django
  ];

  format = "setuptools";
  pythonImportsCheck = [ "sekizai" ];

  meta = {
    description = "Define placeholders where your blocks get rendered and append to those blocks";
    homepage = "https://github.com/django-cms/django-sekizai";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ onny ];
  };
}
