{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-django,
  pytestCheckHook,
  setuptools,
  wheel,
}:
buildPythonPackage rec {
  pname = "django-probes";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "painless-software";
    repo = "django-probes";
    rev = version;
    hash = "sha256-opto5AAUPhEsWbYh7nItUw7qNoUfOFFZ7tw5agWGBSg=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-django
  ];

  build-system = [
    setuptools
    wheel
  ];

  pyproject = true;

  pythonImportsCheck = [
    "django_probes"
  ];

  meta = {
    description = "Django app to run database liveness probe in a Kubernetes project";
    homepage = "https://github.com/painless-software/django-probes";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      LorenzBischof
      jcollie
    ];
  };
}
