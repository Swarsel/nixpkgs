{
  lib,
  stdenv,
  fetchurl,
  jre,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tessera";
  version = "0.10.2";

  src = fetchurl {
    url = "https://oss.sonatype.org/service/local/repositories/releases/content/com/jpmorgan/quorum/tessera-app/${finalAttrs.version}/tessera-app-${finalAttrs.version}-app.jar";
    sha256 = "1zn8w7q0q5man0407kb82lw4mlvyiy9whq2f6izf2b5415f9s0m4";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    makeWrapper ${jre}/bin/java $out/bin/tessera --add-flags "-jar $src"
  '';

  dontUnpack = true;

  meta = {
    description = "Enterprise Implementation of Quorum's transaction manager";
    homepage = "https://github.com/jpmorganchase/tessera";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ mmahut ];
    mainProgram = "tessera";
  };
})
