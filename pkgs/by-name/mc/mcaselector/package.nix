{
  lib,
  fetchurl,
  jre,
  makeWrapper,
  stdenvNoCC,
  wrapGAppsHook3,
}:
let
  jre' = jre.override {
    enableJavaFX = true;
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "mcaselector";
  version = "2.8";

  src = fetchurl {
    url = "https://github.com/Querz/mcaselector/releases/download/${finalAttrs.version}/mcaselector-${finalAttrs.version}.jar";
    hash = "sha256-ZFBfOe35ybXUfmZpgfgePDqInU8SKzBlr34mn0jlNCM=";
  };

  nativeBuildInputs = [
    jre'
    makeWrapper
    wrapGAppsHook3
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib/mcaselector}
    cp $src $out/lib/mcaselector/mcaselector.jar

    runHook postInstall
  '';

  preFixup = ''
    makeWrapper ${jre'}/bin/java $out/bin/mcaselector \
      --add-flags "-jar $out/lib/mcaselector/mcaselector.jar" \
      ''${gappsWrapperArgs[@]}
  '';

  dontBuild = true;
  dontUnpack = true;
  dontWrapGApps = true;

  meta = {
    description = "Tool to select chunks from Minecraft worlds for deletion or export";
    homepage = "https://github.com/Querz/mcaselector";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = [ lib.maintainers.Scrumplex ];
    platforms = lib.platforms.linux;
    mainProgram = "mcaselector";
  };
})
