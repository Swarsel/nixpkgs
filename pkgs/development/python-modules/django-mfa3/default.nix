{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  fido2,
  pyotp,
  python,
  qrcode,
  setuptools,
}:

buildPythonPackage rec {
  pname = "django-mfa3";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "xi";
    repo = "django-mfa3";
    tag = version;
    hash = "sha256-J31NiqOysOS6FFDCaCiPAJUBvD0Xu99sIykLxfk0M3U=";
  };

  checkPhase = ''
    ${python.interpreter} -m django test --settings tests.settings
  '';

  build-system = [ setuptools ];

  dependencies = [
    django
    pyotp
    fido2
    qrcode
  ];

  pyproject = true;
  # qrcode 8.0 not supported yet
  # See https://github.com/xi/django-mfa3/pull/14
  pythonRelaxDeps = [ "qrcode" ];

  meta = {
    description = "Multi factor authentication for Django";
    homepage = "https://github.com/xi/django-mfa3";
    changelog = "https://github.com/xi/django-mfa3/blob/${src.rev}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.onny ];
  };
}
