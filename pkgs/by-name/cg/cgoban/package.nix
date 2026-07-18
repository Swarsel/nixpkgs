{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  temurin-jre-bin-17,
}:
stdenv.mkDerivation {
  pname = "cgoban";
  version = "3.5.144";

  src = fetchurl {
    url = "https://web.archive.org/web/20240314222506/https://files.gokgs.com/javaBin/cgoban.jar";
    hash = "sha256-ehN/aQU23ZEtDh/+r3H2PDPBrWhgoMfgEfKq5q08kFY=";
  };

  nativeBuildInputs = [
    temurin-jre-bin-17
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall
    install -D $src $out/lib/cgoban.jar
    makeWrapper ${temurin-jre-bin-17}/bin/java $out/bin/cgoban --add-flags "-jar $out/lib/cgoban.jar"
    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;
  dontPatchELF = true;
  dontUnpack = true;

  meta = {
    description = "Client for the KGS Go Server";
    homepage = "https://www.gokgs.com/";
    license = lib.licenses.free;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = [ ];
    platforms = temurin-jre-bin-17.meta.platforms;
    mainProgram = "cgoban";
  };
}
