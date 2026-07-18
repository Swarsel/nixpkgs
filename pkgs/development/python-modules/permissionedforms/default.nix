{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  django-modelcluster,
  python,
}:

buildPythonPackage rec {
  pname = "permissionedforms";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "wagtail";
    repo = "django-permissionedforms";
    rev = "v${version}";
    sha256 = "sha256-DQzPGmh5UEVpGWnW3IrEVPkZZ8mdiW9J851Ej4agTDc=";
  };

  propagatedBuildInputs = [ django ];
  checkInputs = [ django-modelcluster ];

  checkPhase = ''
    ${python.interpreter} runtests.py
  '';

  format = "setuptools";
  pythonImportsCheck = [ "permissionedforms" ];

  meta = {
    description = "Django extension for creating forms that vary according to user permissions";
    homepage = "https://github.com/wagtail/django-permissionedforms";
    changelog = "https://github.com/wagtail/django-permissionedforms/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ sephi ];
  };
}
