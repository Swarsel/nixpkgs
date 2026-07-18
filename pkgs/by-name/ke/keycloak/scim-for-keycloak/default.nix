{
  lib,
  fetchFromGitHub,
  maven,
}:

maven.buildMavenPackage rec {
  pname = "scim-for-keycloak";
  version = "kc-20-b1"; # When updating also update mvnHash

  src = fetchFromGitHub {
    owner = "Captain-P-Goldfish";
    repo = "scim-for-keycloak";
    tag = version;
    hash = "sha256-kHjCVkcD8C0tIaMExDlyQmcWMhypisR1nyG93laB8WU=";
  };

  installPhase = ''
    install -D "scim-for-keycloak-server/target/scim-for-keycloak-${version}.jar" "$out/scim-for-keycloak-${version}.jar"
  '';

  mvnHash = "sha256-cOuJSU57OuP+U7lI+pDD7g9HPIfZAoDPYLf+eO+XuF4=";

  meta = {
    description = "Third party module that extends Keycloak with SCIM functionality";
    homepage = "https://github.com/Captain-P-Goldfish/scim-for-keycloak";
    license = lib.licenses.bsd3;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode # dependencies
    ];

    maintainers = with lib.maintainers; [ mkg20001 ];
  };
}
