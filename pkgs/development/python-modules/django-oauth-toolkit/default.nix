{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # propagates
  django,
  # tests
  djangorestframework,
  jwcrypto,
  oauthlib,
  pytest-cov-stub,
  pytest-django,
  pytest-mock,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "django-oauth-toolkit";
  version = "3.3.0";

  src = fetchFromGitHub {
    owner = "jazzband";
    repo = "django-oauth-toolkit";
    tag = finalAttrs.version;
    hash = "sha256-eRQzAFUvSgoDiP7LW/+hMrNxHuXVxY+wc/E3VU/zeXo=";
  };

  # xdist is disabled right now because it can cause race conditions on high core machines
  # https://github.com/jazzband/django-oauth-toolkit/issues/1300
  nativeCheckInputs = [
    djangorestframework
    pytest-cov-stub
    pytest-django
    # pytest-xdist
    pytest-mock
    pytestCheckHook
  ];

  preCheck = ''
    export DJANGO_SETTINGS_MODULE=tests.settings
  '';

  build-system = [ setuptools ];

  dependencies = [
    django
    jwcrypto
    oauthlib
    requests
  ];

  disabledTests = [
    # Failed to get a valid response from authentication server. Status code: 404, Reason: Not Found.
    "test_response_when_auth_server_response_return_404"
  ];

  pyproject = true;

  meta = {
    description = "OAuth2 goodies for the Djangonauts";
    homepage = "https://github.com/jazzband/django-oauth-toolkit";
    changelog = "https://github.com/jazzband/django-oauth-toolkit/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
})
