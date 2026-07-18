{
  lib,
  buildPythonPackage,
  django,
  django-otp,
  djangorestframework,
  fetchPypi,
  hatchling,
  webauthn,
}:

buildPythonPackage rec {
  pname = "django-otp-webauthn";
  version = "0.8.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-GMkKL+U7CPfw3WaSlsnoi0VmEPF/wbb86phfl01NM6I=";
    pname = "django_otp_webauthn";
  };

  build-system = [ hatchling ];

  dependencies = [
    django
    django-otp
    djangorestframework
    webauthn
  ];

  pyproject = true;
  # Tests are on the roadmap, but not yet implemented
  pythonImportsCheck = [ "django_otp_webauthn" ];

  meta = {
    description = "Passkey support for Django";
    homepage = "https://github.com/Stormbase/django-otp-webauthn";
    changelog = "https://github.com/Stormbase/django-otp-webauthn/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ erictapen ];
  };

}
