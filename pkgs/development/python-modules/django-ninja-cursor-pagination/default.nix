{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  django-ninja,
  hatch-vcs,
  hatchling,
  pytest-django,
  pytestCheckHook,
}:

buildPythonPackage {
  pname = "django-ninja-cursor-pagination";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "kitware-resonant";
    repo = "django-ninja-cursor-pagination";
    rev = "2cc22187885b9a12956530a00e554c7a6012de63";
    hash = "sha256-uZ+l/s70A8UG/HlSLIXW4r2WFM0Jj1Ep7fGoNdH9P5M=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-django
  ];

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    django
    django-ninja
  ];

  pyproject = true;

  meta = {
    description = "Django Ninja extension for cursor-based pagination";
    homepage = "https://github.com/kitware-resonant/django-ninja-cursor-pagination";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ defelo ];
  };
}
