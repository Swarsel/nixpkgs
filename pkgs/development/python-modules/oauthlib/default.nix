{
  lib,
  fetchFromGitHub,
  blinker,
  buildPythonPackage,
  cryptography,
  # for passthru.tests
  django-allauth,
  django-oauth-toolkit,
  google-auth-oauthlib,
  mock,
  pyjwt,
  pytestCheckHook,
  requests-oauthlib,
  setuptools,
}:

buildPythonPackage rec {
  pname = "oauthlib";
  version = "3.3.1";

  src = fetchFromGitHub {
    owner = "oauthlib";
    repo = "oauthlib";
    tag = "v${version}";
    hash = "sha256-ZTmR+pTNQaRQMnUA+8hXM5VACRd8Hn62KTNooy5FQyk=";
  };

  nativeBuildInputs = [ setuptools ];

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  disabledTests = [
    # too narrow time comparison issues
    "test_fetch_access_token"
  ];

  optional-dependencies = {
    rsa = [ cryptography ];
    signals = [ blinker ];

    signedtoken = [
      cryptography
      pyjwt
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "oauthlib" ];

  passthru.tests = {
    inherit
      django-allauth
      django-oauth-toolkit
      google-auth-oauthlib
      requests-oauthlib
      ;
  };

  meta = {
    description = "Generic, spec-compliant, thorough implementation of the OAuth request-signing logic";
    homepage = "https://github.com/oauthlib/oauthlib";
    changelog = "https://github.com/oauthlib/oauthlib/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ prikhi ];
  };
}
