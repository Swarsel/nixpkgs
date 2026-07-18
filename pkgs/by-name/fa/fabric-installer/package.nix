{
  lib,
  stdenv,
  fetchurl,
  jre,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fabric-installer";
  version = "1.1.1";

  src = fetchurl {
    url = "https://maven.fabricmc.net/net/fabricmc/fabric-installer/${finalAttrs.version}/fabric-installer-${finalAttrs.version}.jar";
    hash = "sha256-JIemndb52cJgUmWnFC13wmq2LtxiDmvPgQ1YHS7jG3k=";
  };

  nativeBuildInputs = [
    jre
    makeWrapper
  ];

  installPhase = ''
    mkdir -p $out/{bin,lib/fabric}

    cp $src $out/lib/fabric/fabric-installer.jar
    makeWrapper ${jre}/bin/java $out/bin/fabric-installer \
      --add-flags "-jar $out/lib/fabric/fabric-installer.jar"
  '';

  dontUnpack = true;

  meta = {
    description = "Lightweight, experimental modding toolchain for Minecraft";
    homepage = "https://fabricmc.net/";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "fabric-installer";
  };
})
