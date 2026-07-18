{
  lib,
  fetchurl,
  jre,
  makeWrapper,
  runCommand,
  sha256,
  version,
}:

let
  mcVersion = builtins.head (lib.splitString "_" version);
in
runCommand "optifine-${mcVersion}"
  {
    inherit version;
    pname = "optifine";

    src = fetchurl {
      inherit sha256;
      url = "https://optifine.net/download?f=OptiFine_${version}.jar";
      name = "OptiFine_${version}.jar";
    };

    nativeBuildInputs = [
      jre
      makeWrapper
    ];

    passthru.updateScript = {
      command = [ ./update.py ];
      supportedFeatures = [ "commit" ];
    };

    meta = {
      description = "Minecraft ${mcVersion} optimization mod";

      longDescription = ''
        OptiFine is a Minecraft optimization mod.
        It allows Minecraft to run faster and look better with full support for HD textures and many configuration options.
        This is for version ${mcVersion} of Minecraft.
      '';

      homepage = "https://optifine.net/";
      license = lib.licenses.unfree;
      sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
      maintainers = [ ];
      platforms = lib.platforms.unix;
      mainProgram = "optifine";
    };
  }
  ''
    mkdir -p $out/{bin,lib/optifine}
    cp $src $out/lib/optifine/optifine.jar

    makeWrapper ${jre}/bin/java $out/bin/optifine \
      --add-flags "-jar $out/lib/optifine/optifine.jar"
  ''
