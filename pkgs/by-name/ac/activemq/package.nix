{
  lib,
  fetchurl,
  stdenvNoCC,
}:

let
  version = "6.2.4";
in
stdenvNoCC.mkDerivation {
  inherit version;
  pname = "activemq";

  src = fetchurl {
    url = "mirror://apache/activemq/${version}/apache-activemq-${version}-bin.tar.gz";
    hash = "sha256-/jvyO8cDQ666i8J53SXPS5WyBmN5GZwK6TVaDxXxJhM=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    mv * $out/
    for j in $(find $out/lib -name "*.jar"); do
      cp="''${cp:+"$cp:"}$j";
    done
    echo "CLASSPATH=$cp" > $out/lib/classpath.env

    runHook postInstall
  '';

  meta = {
    description = "Messaging and Integration Patterns server written in Java";
    homepage = "https://activemq.apache.org/";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = [ lib.maintainers.anthonyroussel ];
    platforms = lib.platforms.unix;
    mainProgram = "activemq";
  };
}
