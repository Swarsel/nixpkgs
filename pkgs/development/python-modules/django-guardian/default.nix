{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  django-environ,
  pytest-django,
  pytest-xdist,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "django-guardian";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "django-guardian";
    repo = "django-guardian";
    tag = version;
    hash = "sha256-imisHa5DOIQrQCEPWC/0EqPjDq12tR3xr0Dl1VifJoI=";
  };

  nativeCheckInputs = [
    django-environ
    pytestCheckHook
    pytest-django
    pytest-xdist
  ];

  build-system = [ setuptools ];
  dependencies = [ django ];
  pyproject = true;
  pythonImportsCheck = [ "guardian" ];

  meta = {
    description = "Per object permissions for Django";
    homepage = "https://github.com/django-guardian/django-guardian";
    license = with lib.licenses; [ bsd2 ];
    maintainers = [ ];
  };
}
