{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  openldap,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "slapd";
  version = "0.1.6";

  # Pypi tarball doesn't include tests/
  src = fetchFromGitHub {
    owner = "python-ldap";
    repo = "python-slapd";
    tag = version;
    hash = "sha256-xXIKC8xDJ3Q6yV1BL5Io0PkLqVbFRbbkB0QSXQGHMNg=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    # Needed by tests to setup a mockup ldap server
    export BIN="${openldap}/bin"
    export SBIN="${openldap}/bin"
    export SLAPD="${openldap}/libexec/slapd"
    export SCHEMA="${openldap}/etc/schema"
  '';

  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "slapd" ];

  meta = {
    description = "Controls a slapd process in a pythonic way";
    homepage = "https://github.com/python-ldap/python-slapd";
    changelog = "https://github.com/python-ldap/python-slapd/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ erictapen ];
  };

}
