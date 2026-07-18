{
  lib,
  fetchurl,
  makeWrapper,
  stdenvNoCC,
  unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "loopwm";
  version = "1.4.2";

  src = fetchurl {
    url = "https://github.com/MrKai77/Loop/releases/download/${finalAttrs.version}/Loop.zip";
    hash = "sha256-UU6X+qs4Q837ixhZuRMzcEY5oaLOWA5PaE117+AH04Y=";
  };

  nativeBuildInputs = [
    unzip
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/{Applications,bin}
    cp -r Loop.app $out/Applications
    makeWrapper $out/Applications/Loop.app/Contents/MacOS/Loop $out/bin/loopwm \
      --set LOOP_SKIP_UPDATE_CHECK 1
    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;
  dontPatch = true;
  sourceRoot = ".";

  passthru = {
    updateScript = ./update.sh;
  };

  meta = {
    description = "macOS Window management made elegant";
    homepage = "https://github.com/MrKai77/Loop";
    license = lib.licenses.gpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ matteopacini ];
    platforms = lib.platforms.darwin;
    mainProgram = "loopwm";
  };
})
