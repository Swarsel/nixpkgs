{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  django,
  djangorestframework,
  pyjwt,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "mozilla-django-oidc";
  version = "5.0.2";

  src = fetchFromGitHub {
    owner = "mozilla";
    repo = "mozilla-django-oidc";
    tag = version;
    hash = "sha256-5J2lzGGdjoXzdzfKdmfUaSM7KQ6Hn7KerBtoKzFsZfY=";
  };

  nativeCheckInputs = [
    djangorestframework
  ];

  checkPhase = ''
    runHook preCheck

    PYTHONPATH=.:$PYTHONPATH DJANGO_SETTINGS_MODULE=tests.settings django-admin test

    runHook postCheck
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    django
    pyjwt
    requests
    cryptography
  ];

  pyproject = true;

  meta = {
    description = "Django OpenID Connect library";
    homepage = "https://github.com/mozilla/mozilla-django-oidc";
    changelog = "https://github.com/mozilla/mozilla-django-oidc/releases/tag/${src.tag}";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ felbinger ];
  };
}
