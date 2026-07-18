{
  lib,
  stdenv,
  fetchMavenArtifact,
}:

stdenv.mkDerivation rec {
  pname = "sqlite-jdbc";
  version = "3.49.1.0";

  src = fetchMavenArtifact {
    inherit version;
    hash = "sha256-XIYJ0so0HeuMb3F3iXS1ukmVx9MtfHyJ2TkqPnLDkpE=";
    artifactId = "sqlite-jdbc";
    groupId = "org.xerial";
  };

  installPhase = ''
    install -m444 -D ${src}/share/java/*${pname}-${version}.jar "$out/share/java/${pname}-${version}.jar"
  '';

  meta = {
    description = "Library for accessing and creating SQLite database files in Java";
    homepage = "https://github.com/xerial/sqlite-jdbc";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ jraygauthier ];
    platforms = lib.platforms.linux;
  };
}
