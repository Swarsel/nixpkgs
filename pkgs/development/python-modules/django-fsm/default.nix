{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  django-guardian,
  python,
  setuptools,
}:

buildPythonPackage rec {
  pname = "django-fsm";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "viewflow";
    repo = "django-fsm";
    tag = version;
    hash = "sha256-woN0F4hTaPk8HTGNT6zQlZDJ9SCVRut9maKSlDmalUE=";
  };

  checkInputs = [ django-guardian ];

  checkPhase = ''
    ${python.interpreter} tests/manage.py test
  '';

  build-system = [ setuptools ];
  dependencies = [ django ];
  pyproject = true;
  pythonImportsCheck = [ "django_fsm" ];

  meta = {
    description = "Django friendly finite state machine support";
    homepage = "https://github.com/viewflow/django-fsm";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.onny ];
    knownVulnerabilities = [ "Package is marked as discontinued upstream." ];
  };
}
