{
  lib,
  stdenv,
  fetchMavenArtifact,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "liquibase-redshift-extension";
  version = "4.8.0";

  src = fetchMavenArtifact {
    inherit (finalAttrs) version;
    sha256 = "sha256-jZdDKAC4Cvmkih8VH84Z3Q8BzsqGO55Uefr8vOlbDAk=";
    artifactId = "liquibase-redshift";
    groupId = "org.liquibase.ext";
  };

  installPhase = ''
    runHook preInstall
    install -m444 -D $src/share/java/liquibase-redshift-${finalAttrs.version}.jar $out/share/java/liquibase-redshift.jar
    runHook postInstall
  '';

  meta = {
    description = "Amazon Redshift extension for Liquibase";
    homepage = "https://github.com/liquibase/liquibase-redshift/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ sir4ur0n ];
    platforms = lib.platforms.unix;
  };
})
