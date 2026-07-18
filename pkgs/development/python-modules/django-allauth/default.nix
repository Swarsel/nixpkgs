{
  lib,
  # dependencies
  asgiref,
  buildPythonPackage,
  # passthru tests
  dj-rest-auth,
  django,
  # tests
  django-ninja,
  djangorestframework,
  fetchFromCodeberg,
  # optional-dependencies
  fido2,
  # build-time dependencies
  gettext,
  oauthlib,
  pillow,
  psycopg2,
  pyjwt,
  pytest-asyncio,
  pytest-django,
  pytestCheckHook,
  python,
  python3-openid,
  python3-saml,
  pyyaml,
  qrcode,
  requests,
  requests-oauthlib,
  # build-system
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "django-allauth";
  version = "65.18.0";

  src = fetchFromCodeberg {
    owner = "allauth";
    repo = "django-allauth";
    tag = version;
    hash = "sha256-OUU42yld3CTutgu7XOkC/f4U2Yo9HpQV8GCfZsM2P5w=";
  };

  nativeBuildInputs = [ gettext ];

  preBuild = ''
    ${python.pythonOnBuildForHost.interpreter} -m django compilemessages
  '';

  nativeCheckInputs = [
    django-ninja
    djangorestframework
    pillow
    psycopg2
    pytest-asyncio
    pytest-django
    pytestCheckHook
    pyyaml
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    asgiref
    django
  ];

  disabledTests = [
    # Tests require network access
    "test_login"
  ];

  optional-dependencies = {
    headless = [
      pyjwt
    ]
    ++ pyjwt.optional-dependencies.crypto;

    headless-spec = [ pyyaml ];

    idp-oidc = [
      oauthlib
      pyjwt
    ]
    ++ pyjwt.optional-dependencies.crypto;

    mfa = [
      fido2
      qrcode
    ];

    openid = [ python3-openid ];
    saml = [ python3-saml ];

    socialaccount = [
      requests
      requests-oauthlib
      pyjwt
    ]
    ++ pyjwt.optional-dependencies.crypto;

    steam = [ python3-openid ];
  };

  pyproject = true;
  pythonImportsCheck = [ "allauth" ];
  passthru.tests = { inherit dj-rest-auth; };

  meta = {
    description = "Integrated set of Django applications addressing authentication, registration, account management as well as 3rd party (social) account authentication";
    homepage = "https://allauth.org";
    changelog = "https://codeberg.org/allauth/django-allauth/src/tag/${src.tag}/ChangeLog.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ derdennisop ];
    downloadPage = "https://codeberg.org/allauth/django-allauth";
  };
}
