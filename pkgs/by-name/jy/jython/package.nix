{
  lib,
  stdenv,
  fetchurl,
  jre,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jython";
  version = "2.7.4";

  src = fetchurl {
    url = "https://search.maven.org/remotecontent?filepath=org/python/jython-standalone/${finalAttrs.version}/jython-standalone-${finalAttrs.version}.jar";
    sha256 = "sha256-H7oXae/8yLGfXhBDa8gnShWM6YhVnyV5J8JMc7sTfzw=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -pv $out/bin
    cp $src $out/jython.jar
    makeWrapper ${jre}/bin/java $out/bin/jython --add-flags "-jar $out/jython.jar"
  '';

  dontUnpack = true;

  meta = {
    description = "Python interpreter written in Java";
    homepage = "https://jython.org/";
    license = lib.licenses.psfl;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    platforms = jre.meta.platforms;
    mainProgram = "jython";
  };
})
