{
  lib,
  fetchFromGitHub,
  maven,
}:
maven.buildMavenPackage rec {
  pname = "keycloak-orgs";
  version = "0.126";

  src = fetchFromGitHub {
    owner = "p2-inc";
    repo = "keycloak-orgs";
    tag = "v${version}";
    hash = "sha256-AQvIkmm8YJoNMcN+85OEbBud7YDLAlk5NfC05js1k2Y=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm644 -t "$out" target/keycloak-orgs-${version}.jar
    runHook postInstall
  '';

  mvnHash = "sha256-lq3N0XBRyR9I6U0gvjsjJ9r6fZINSsTWAMvdDEIsT0g=";
  # Tell buildnumber-maven-plugin to use a fallback value because git/.git aren't present
  mvnParameters = "-Dmaven.buildNumber.revisionOnScmFailure=v${version} -DskipTests";

  meta = {
    description = "Multi-tenancy on a single Keycloak realm via first-class organization objects";
    homepage = "https://github.com/p2-inc/keycloak-orgs";
    license = lib.licenses.elastic20;
    maintainers = with lib.maintainers; [ anish ];
  };
}
