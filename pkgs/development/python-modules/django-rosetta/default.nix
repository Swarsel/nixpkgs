{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  polib,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "django-rosetta";
  version = "0.10.3";

  src = fetchFromGitHub {
    owner = "mbi";
    repo = "django-rosetta";
    tag = "v${version}";
    hash = "sha256-VnKbtzLY2+3RTk4gNZASuVSDGzfgoyr06RUNB2r0eDw=";
  };

  # require internet connection
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    django
    polib
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "rosetta" ];

  meta = {
    description = "Rosetta is a Django application that facilitates the translation process of your Django projects";
    homepage = "https://github.com/mbi/django-rosetta";
    changelog = "https://github.com/mbi/django-rosetta/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ derdennisop ];
  };
}
