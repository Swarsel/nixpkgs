{
  lib,
  stdenv,
  fetchzip,
  jre,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jacoco";
  version = "0.8.14";

  src = fetchzip {
    url = "https://search.maven.org/remotecontent?filepath=org/jacoco/jacoco/${finalAttrs.version}/jacoco-${finalAttrs.version}.zip";
    sha256 = "sha256-ysqPAxZK/mcnGiqqqTzfCOCyAcvMMvymFrSme6rFCJE=";
    stripRoot = false;
  };

  outputs = [
    "out"
    "doc"
  ];

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $doc/share/doc $out/bin

    cp -r doc $doc/share/doc/jacoco
    install -Dm444 lib/* -t $out/share/java

    makeWrapper ${jre}/bin/java $out/bin/jacoco \
      --add-flags "-jar $out/share/java/jacococli.jar"

    runHook postInstall
  '';

  meta = {
    description = "Free code coverage library for Java";
    homepage = "https://www.jacoco.org/jacoco";
    changelog = "https://www.jacoco.org/jacoco/trunk/doc/changes.html";
    license = lib.licenses.epl20;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "jacoco";
  };
})
