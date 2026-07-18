{
  lib,
  fetchurl,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "guacamole-client";
  version = "1.6.0";

  src = fetchurl {
    url = "mirror://apache/guacamole/${finalAttrs.version}/binary/guacamole-${finalAttrs.version}.war";
    hash = "sha256-tBzrHi3wELVNtWPgsA7bjV/p8HPGFoRi5Ml43w/G5xY=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/webapps
    cp $src $out/webapps/guacamole.war

    runHook postInstall
  '';

  dontBuild = true;
  dontUnpack = true;

  meta = {
    description = "Clientless remote desktop gateway";
    homepage = "https://guacamole.apache.org/";
    license = lib.licenses.asl20;

    sourceProvenance = [
      lib.sourceTypes.binaryBytecode
    ];

    maintainers = [ ];

    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];
  };
})
