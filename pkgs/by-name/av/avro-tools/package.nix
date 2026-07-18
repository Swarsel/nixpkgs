{
  lib,
  stdenv,
  fetchurl,
  jre,
  makeWrapper,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "avro-tools";
  version = "1.12.0";

  src = fetchurl {
    url = "mirror://maven/org/apache/avro/avro-tools/${finalAttrs.version}/avro-tools-${finalAttrs.version}.jar";
    sha256 = "sha256-+OTQ2UWFLcL5HDv4j33LjKvADg/ClbuS6JPlSUXggIU=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ jre ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/libexec/avro-tools
    cp $src $out/libexec/avro-tools/avro-tools.jar

    makeWrapper ${jre}/bin/java $out/bin/avro-tools \
    --add-flags "-jar $out/libexec/avro-tools/avro-tools.jar"
  '';

  dontUnpack = true;
  sourceRoot = ".";

  meta = {
    description = "Avro command-line tools and utilities";
    homepage = "https://avro.apache.org/";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = [ ];
    mainProgram = "avro-tools";
  };
})
