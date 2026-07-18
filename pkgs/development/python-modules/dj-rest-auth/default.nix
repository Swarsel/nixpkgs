{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  django-allauth,
  djangorestframework,
  djangorestframework-simplejwt,
  pyotp,
  pytest-django,
  pytestCheckHook,
  python,
  responses,
  setuptools,
  unittest-xml-reporting,
}:

buildPythonPackage (finalAttrs: {
  pname = "dj-rest-auth";
  version = "7.2.0";

  src = fetchFromGitHub {
    owner = "iMerica";
    repo = "dj-rest-auth";
    tag = finalAttrs.version;
    hash = "sha256-eUcve2KPcLjKKWU7AxQEZ0mokP185E43Xjm4b+4hQzA=";
  };

  buildInputs = [ django ];
  env.DJANGO_SETTINGS_MODULE = "dj_rest_auth.tests.settings";

  nativeCheckInputs = [
    pytest-django
    djangorestframework-simplejwt
    pytestCheckHook
    pytest-django
    responses
    unittest-xml-reporting
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  preCheck = ''
    # Make tests module available for the checkPhase
    export PYTHONPATH=$out/${python.sitePackages}/dj_rest_auth:$PYTHONPATH
  '';

  build-system = [ setuptools ];
  dependencies = [ djangorestframework ];

  disabledTests = [
    # Test connects to graph.facebook.com
    "TestSocialLoginSerializer"
  ];

  optional-dependencies = {
    with_mfa = [
      pyotp
    ];

    with_social = [
      django-allauth
    ]
    ++ django-allauth.optional-dependencies.socialaccount;
  };

  pyproject = true;
  pythonImportsCheck = [ "dj_rest_auth" ];

  meta = {
    description = "Authentication for Django Rest Framework";
    homepage = "https://github.com/iMerica/dj-rest-auth";
    changelog = "https://github.com/iMerica/dj-rest-auth/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ onny ];
  };
})
