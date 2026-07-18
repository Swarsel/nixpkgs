{
  lib,
  fetchFromGitHub,
  mkDiscoursePlugin,
}:

mkDiscoursePlugin {
  src = fetchFromGitHub {
    owner = "jonmbake";
    repo = "discourse-ldap-auth";
    rev = "0f5749ca6443d63999f78ed8eac49dead1b322bc";
    sha256 = "sha256-QquREAexMJjza+TtDveqJ3/sgjPCziv2oje4fKL6uz4=";
  };

  bundlerEnvArgs.gemdir = ./.;
  name = "discourse-ldap-auth";
  pluginName = "ldap";

  meta = {
    description = "Discourse plugin to enable LDAP/Active Directory authentication";
    homepage = "https://github.com/jonmbake/discourse-ldap-auth";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ryantm ];
  };
}
