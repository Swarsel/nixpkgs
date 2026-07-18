{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  hatch-vcs,
  hatchling,
  python,
}:

buildPythonPackage rec {
  pname = "django-pwa";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "silviolleite";
    repo = "django-pwa";
    tag = version;
    hash = "sha256-EAjDK3rkjoPw8jyVVZdhMNHmTqr0/ERiMwGMxmVbsls=";
  };

  checkPhase = ''
    runHook preCheck
    ${python.interpreter} runtests.py
    runHook postCheck
  '';

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [ django ];
  pyproject = true;
  pythonImportsCheck = [ "pwa" ];

  meta = {
    description = "Django app to include a manifest.json and Service Worker instance to enable progressive web app behavior";
    homepage = "https://github.com/silviolleite/django-pwa";
    changelog = "https://github.com/silviolleite/django-pwa/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ derdennisop ];
  };
}
