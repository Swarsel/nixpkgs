{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  jupyterhub,
  ldap3,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  traitlets,
}:

buildPythonPackage rec {
  pname = "jupyterhub-ldapauthenticator";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "jupyterhub";
    repo = "ldapauthenticator";
    tag = version;
    hash = "sha256-xixgry/++E6RimB8wo1NF8SsfzxKL1ZlNQVrlBhQ674=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    jupyterhub
    ldap3
    traitlets
  ];

  disabledTests = [
    # touch the socket
    "test_allow_config"
    "test_ldap_auth"
  ];

  pyproject = true;
  pythonImportsCheck = [ "ldapauthenticator" ];

  meta = {
    description = "Simple LDAP Authenticator Plugin for JupyterHub";
    homepage = "https://github.com/jupyterhub/ldapauthenticator";
    changelog = "https://github.com/jupyterhub/ldapauthenticator/blob/${version}/CHANGELOG.md";
    license = lib.licenses.bsd3;
  };
}
