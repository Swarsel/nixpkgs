{
  lib,
  fetchFromGitHub,
  jre,
  makeWrapper,
  maven,
}:

maven.buildMavenPackage rec {
  pname = "joularjx";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "joular";
    repo = "joularjx";
    rev = version;
    hash = "sha256-hr8a3Qr1LdFfGBLVJVkm6hhCW7knG4VpXj7nCtcptuU=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share
    cp target/joularjx-${version}.jar $out/share/joularjx.jar
    makeWrapper ${jre}/bin/java $out/bin/joularjx \
      --add-flags "-javaagent:$out/share/joularjx.jar"
    runHook postInstall
  '';

  mvnHash = "sha256-XXqpajmHCjDxMZvYnW7EiCsPIuWF8tsE7RmI/gt3iZQ=";
  mvnParameters = "-DskipTests -Dmaven.javadoc.skip=true";

  meta = {
    description = "Java-based agent for software power monitoring at the source code level";
    homepage = "https://github.com/joular/joularjx";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ julienmalka ];
    platforms = lib.platforms.linux;
  };
}
