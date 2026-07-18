{
  lib,
  stdenv,
  fetchurl,
  jre,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "macse";
  version = "2.03";

  src = fetchurl {
    url = "https://bioweb.supagro.inra.fr/macse/releases/macse_v${finalAttrs.version}.jar";
    sha256 = "0jnjyz4f255glg37rawzdv4m6nfs7wfwc5dny7afvx4dz2sv4ssh";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/java
    cp -s $src $out/share/java/macse.jar
    makeWrapper ${jre}/bin/java $out/bin/macse --add-flags "-jar $out/share/java/macse.jar"
    runHook postInstall
  '';

  dontBuild = true;
  dontUnpack = true;

  meta = {
    description = "Multiple alignment of coding sequences";
    homepage = "https://bioweb.supagro.inra.fr/macse/";
    license = lib.licenses.gpl2;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = [ lib.maintainers.bzizou ];
    platforms = lib.platforms.all;
    mainProgram = "macse";
  };
})
