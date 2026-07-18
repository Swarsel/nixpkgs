{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  python,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "django-widget-tweaks";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "jazzband";
    repo = "django-widget-tweaks";
    tag = version;
    hash = "sha256-ymjBuNGfndUwQdBU2xnc9CA51oOaEPA+RaAspJMKQ04=";
  };

  checkPhase = ''
    ${python.interpreter} -m django test --settings=tests.settings
  '';

  build-system = [ setuptools-scm ];
  dependencies = [ django ];
  pyproject = true;

  meta = {
    description = "Tweak the form field rendering in templates, not in python-level form definitions";
    homepage = "https://github.com/jazzband/django-widget-tweaks";
    changelog = "https://github.com/jazzband/django-widget-tweaks/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxxk ];
  };
}
