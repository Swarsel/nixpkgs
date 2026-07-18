{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  devpi-server,
  ldap3,
  # tests
  packaging-legacy,
  pytest-cov-stub,
  pytest-mock,
  pytestCheckHook,
  pyyaml,
  # build-system
  setuptools,
  webtest,
}:

buildPythonPackage (finalAttrs: {
  pname = "devpi-ldap";
  version = "2.1.1-unstable-2026-01-22";

  src = fetchFromGitHub {
    owner = "devpi";
    repo = "devpi-ldap";
    rev = "5846e66a9206079c16321bd0f65c565ebe32be5f";
    hash = "sha256-2LpreWmG6WMRrc5L7ylSej5Ce6VhfNDAW2eoJ76D49o=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"setuptools_changelog_shortener",' ""
  '';

  nativeCheckInputs = [
    packaging-legacy
    pytest-cov-stub
    pytest-mock
    pytestCheckHook
    webtest
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    devpi-server
    ldap3
    pyyaml
  ];

  pyproject = true;
  pythonImportsCheck = [ "devpi_ldap" ];
  passthru.skipBulkUpdate = true; # avoid reversion to previous stable version

  meta = {
    description = "LDAP authentication for devpi-server";
    homepage = "https://github.com/devpi/devpi-ldap";
    changelog = "https://github.com/devpi/devpi-ldap/blob/${finalAttrs.src.rev}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ confus ];
  };
})
