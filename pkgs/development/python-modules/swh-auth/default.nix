{
  lib,
  stdenv,
  fetchFromGitLab,
  aiocache,
  buildPythonPackage,
  click,
  djangorestframework,
  httpx,
  pytest-django,
  pytest-mock,
  pytestCheckHook,
  python-jose,
  python-keycloak,
  pyyaml,
  setuptools,
  setuptools-scm,
  starlette,
  swh-core,
}:

buildPythonPackage (finalAttrs: {
  pname = "swh-auth";
  version = "0.10.2";

  src = fetchFromGitLab {
    owner = "devel";
    repo = "swh-auth";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fRkhSpgguBff+vIOploi8i2qzd9qmsswiC62rIcY5bE=";
    domain = "gitlab.softwareheritage.org";
    group = "swh";
  };

  # Many broken tests on Darwin. Disabling them for now.
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    aiocache
    djangorestframework
    httpx
    pytestCheckHook
    pytest-django
    pytest-mock
    starlette
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    click
    python-keycloak
    python-jose
    pyyaml
    swh-core
  ];

  pyproject = true;
  pythonImportsCheck = [ "swh.auth" ];

  meta = {
    description = "Set of utility libraries related to user authentication in applications and services based on the use of Keycloak and OpenID Connect";
    homepage = "https://gitlab.softwareheritage.org/swh/devel/swh-auth";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ drupol ];
  };
})
