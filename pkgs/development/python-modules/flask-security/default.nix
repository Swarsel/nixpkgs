{
  lib,
  fetchFromGitHub,
  # extras: common
  argon2-cffi,
  # tests
  authlib,
  # extras: babel
  babel,
  bcrypt,
  bleach,
  buildPythonPackage,
  # extras: mfa
  cryptography,
  # propagates
  email-validator,
  flask,
  flask-babel,
  flask-login,
  flask-mail,
  flask-principal,
  # extras: fsqla
  flask-sqlalchemy,
  flask-sqlalchemy-lite,
  flask-wtf,
  flit-core,
  freezegun,
  importlib-resources,
  libpass,
  markupsafe,
  mongoengine,
  mongomock,
  passlib,
  peewee,
  phonenumberslite,
  pytestCheckHook,
  qrcode,
  requests,
  sqlalchemy,
  sqlalchemy-utils,
  webauthn,
  wtforms,
  zxcvbn,
}:

buildPythonPackage rec {
  pname = "flask-security";
  version = "5.8.1";

  src = fetchFromGitHub {
    owner = "pallets-eco";
    repo = "flask-security";
    tag = version;
    hash = "sha256-xNWgLIk/AB5beZQX7jzh8uQ9o0Gq+W5rgowBS215pk4=";
  };

  nativeCheckInputs = [
    authlib
    flask-sqlalchemy-lite
    freezegun
    mongoengine
    mongomock
    peewee
    pytestCheckHook
    requests
    zxcvbn
  ]
  ++ optional-dependencies.babel
  ++ optional-dependencies.common
  ++ optional-dependencies.fsqla
  ++ optional-dependencies.mfa;

  preCheck = ''
    pybabel compile --domain flask_security -d flask_security/translations
  '';

  build-system = [ flit-core ];

  dependencies = [
    email-validator
    flask
    flask-login
    flask-principal
    flask-wtf
    markupsafe
    libpass
    wtforms
  ];

  disabledTests = [
    # needs /etc/resolv.conf
    "test_login_email_whatever"
  ];

  optional-dependencies = {
    babel = [
      babel
      flask-babel
    ];

    common = [
      argon2-cffi
      bcrypt
      bleach
      flask-mail
    ];

    fsqla = [
      flask-sqlalchemy
      sqlalchemy
    ];

    mfa = [
      cryptography
      phonenumberslite
      webauthn
      qrcode
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "flask_security" ];

  meta = {
    description = "Quickly add security features to your Flask application";
    homepage = "https://github.com/pallets-eco/flask-security";
    changelog = "https://github.com/pallets-eco/flask-security/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ gador ];
  };
}
