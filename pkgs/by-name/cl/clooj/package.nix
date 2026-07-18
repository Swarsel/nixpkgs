{
  lib,
  stdenv,
  fetchurl,
  jre,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "clooj";
  version = "0.4.4";
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/share/java
    ln -s $jar $out/share/java/clooj.jar
    makeWrapper ${jre}/bin/java $out/bin/clooj --add-flags "-jar $out/share/java/clooj.jar"
  '';

  dontUnpack = true;

  jar = fetchurl {
    sha256 = "0hbc29bg2a86rm3sx9kvj7h7db9j0kbnrb706wsfiyk3zi3bavnd";
    # mirrored as original mediafire.com source does not work without user interaction
    url = "https://archive.org/download/clooj-${finalAttrs.version}-standalone/clooj-${finalAttrs.version}-standalone.jar";
  };

  meta = {
    description = "Lightweight IDE for Clojure";
    homepage = "https://github.com/arthuredelstein/clooj";
    license = lib.licenses.bsd3;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    platforms = lib.platforms.all;
    mainProgram = "clooj";
  };
})
