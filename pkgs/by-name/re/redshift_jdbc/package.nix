{
  lib,
  stdenv,
  fetchMavenArtifact,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "redshift-jdbc";
  version = "2.1.0.3";

  src = fetchMavenArtifact {
    inherit (finalAttrs) version;
    sha256 = "sha256-TO/JXh/pZ7tUZGfHqkzgZx18gLnISvnPVyGavzFv6vo=";
    artifactId = "redshift-jdbc42";
    groupId = "com.amazon.redshift";
  };

  installPhase = ''
    runHook preInstall
    install -m444 -D $src/share/java/redshift-jdbc42-${finalAttrs.version}.jar $out/share/java/redshift-jdbc42.jar
    runHook postInstall
  '';

  meta = {
    description = "JDBC 4.2 driver for Amazon Redshift allowing Java programs to connect to a Redshift database";
    homepage = "https://github.com/aws/amazon-redshift-jdbc-driver/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ sir4ur0n ];
    platforms = lib.platforms.unix;
  };
})
