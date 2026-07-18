{
  lib,
  stdenv,
  fetchurl,
  jre,
  makeWrapper,
}:
stdenv.mkDerivation rec {
  pname = "jreleaser-cli";
  version = "1.25.0";

  src = fetchurl {
    url = "https://github.com/jreleaser/jreleaser/releases/download/v${version}/jreleaser-tool-provider-${version}.jar";
    hash = "sha256-ixcHrzCX+b1iEkmk2rWZidFBtT2Ar58pRSGLzwaDYSM=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/share/java/ $out/bin/
    cp $src $out/share/java/${pname}.jar
    makeWrapper ${jre}/bin/java $out/bin/${pname} \
      --add-flags "-jar $out/share/java/${pname}.jar"
  '';

  dontUnpack = true;

  meta = {
    description = "Release projects quickly and easily";
    homepage = "https://jreleaser.org/";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    maintainers = [ lib.maintainers.i-al-istannen ];
    mainProgram = "jreleaser-cli";
  };
}
