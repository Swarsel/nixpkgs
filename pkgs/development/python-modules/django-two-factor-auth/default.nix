{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  django-formtools,
  django-otp,
  django-phonenumber-field,
  phonenumbers,
  pydantic,
  qrcode,
  setuptools-scm,
  twilio,
  webauthn,
}:

buildPythonPackage rec {
  pname = "django-two-factor-auth";
  version = "1.18.1";

  src = fetchFromGitHub {
    owner = "jazzband";
    repo = "django-two-factor-auth";
    tag = version;
    hash = "sha256-rhcEVmh5Am1TKO+01rb9VBKJdFVa8uRdTimEKq2pA7w=";
  };

  # Tests require internet connection
  doCheck = false;
  build-system = [ setuptools-scm ];

  dependencies = [
    django
    django-formtools
    django-otp
    django-phonenumber-field
    qrcode
  ];

  optional-dependencies = {
    call = [ twilio ];
    # yubikey = [
    #   django-otp-yubikey
    # ];
    phonenumbers = [ phonenumbers ];
    sms = [ twilio ];

    webauthn = [
      pydantic
      webauthn
    ];
    # phonenumberslite = [
    #   phonenumberslite
    # ];
  };

  pyproject = true;
  pythonImportsCheck = [ "two_factor" ];

  pythonRelaxDeps = [
    "django-phonenumber-field"
    "qrcode"
  ];

  meta = {
    description = "Complete Two-Factor Authentication for Django";
    homepage = "https://github.com/jazzband/django-two-factor-auth";
    changelog = "https://github.com/jazzband/django-two-factor-auth/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ derdennisop ];
  };
}
