{
  lib,
  fetchFromGitHub,
  jre,
  makeWrapper,
  maven,
  nix-update-script,
}:

maven.buildMavenPackage (finalAttrs: {
  pname = "h2";
  version = "2.4.240";

  src = fetchFromGitHub {
    owner = "h2database";
    repo = "h2database";
    tag = "version-${finalAttrs.version}";
    hash = "sha256-Cy6MoumJBhhcYT6dCHWeOfmhjGRkdNvSONdIiZaf6uU=";
  };

  outputs = [
    "out"
    "doc"
  ];

  nativeBuildInputs = [ makeWrapper ];
  doCheck = false;

  installPhase = ''
    mkdir -p $out/share/java
    install -Dm644 h2/target/h2-${finalAttrs.version}.jar $out/share/java

    makeWrapper ${jre}/bin/java $out/bin/h2 \
      --add-flags "-cp \"$out/share/java/h2-${finalAttrs.version}.jar:\$H2DRIVERS:\$CLASSPATH\" org.h2.tools.Console"

    mkdir -p $doc/share/doc/h2
    cp -r h2/src/docsrc/* $doc/share/doc/h2
  '';

  mvnHash = "sha256-j4Uso/bl4UhQbJc7Wre0btgC+9RKvuCHkn9euQFuTxk=";
  mvnParameters = "-f h2/pom.xml";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "^version-([0-9.]+)$"
    ];
  };

  meta = {
    description = "Java SQL database";
    homepage = "https://h2database.com/html/main.html";
    changelog = "https://h2database.com/html/changelog.html";
    license = lib.licenses.mpl20;

    maintainers = with lib.maintainers; [
      mahe
      anthonyroussel
    ];

    platforms = lib.platforms.unix;
    mainProgram = "h2";
  };
})
