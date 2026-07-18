{
  lib,
  stdenv,
  fetchFromGitHub,
  ant,
  jdk8,
  jre8,
  makeWrapper,
  stripJavaArchivesHook,
}:

let
  jdk = jdk8;
  jre = jre8;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "ili2c";
  version = "5.1.1"; # There are newer versions, but they use gradle

  src = fetchFromGitHub {
    owner = "claeis";
    repo = "ili2c";
    rev = "ili2c-${finalAttrs.version}";
    hash = "sha256-FHhx+f253+UdbFjd2fOlUY1tpQ6pA2aVu9CBSwUVoKQ=";
  };

  patches = [
    # avoids modifying Version.properties file because that would insert the current timestamp into the file
    ./dont-use-build-timestamp.patch
  ];

  nativeBuildInputs = [
    ant
    jdk
    makeWrapper
    stripJavaArchivesHook
  ];

  buildPhase = ''
    runHook preBuild
    ant jar
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 build/jar/ili2c.jar -t $out/share/ili2c
    makeWrapper ${jre}/bin/java $out/bin/ili2c \
        --add-flags "-jar $out/share/ili2c/ili2c.jar"

    runHook postInstall
  '';

  meta = {
    description = "INTERLIS Compiler";

    longDescription = ''
      Checks the syntactical correctness of an INTERLIS data model.
    '';

    homepage = "https://www.interlis.ch/downloads/ili2c";
    license = lib.licenses.lgpl21Plus;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode # source bundles dependencies as jars
    ];

    maintainers = with lib.maintainers; [ das-g ];
    platforms = lib.platforms.unix;
    mainProgram = "ili2c";
    teams = [ lib.teams.geospatial ];
  };
})
