{
  lib,
  fetchurl,
  makeWrapper,
  stdenvNoCC,
  undmg,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "gamemac";
  version = "0.8.328";

  src = fetchurl {
    url = "https://gamehub-cdn.masnet.cn/uploads/upgrade/20260618/b616a96780c249a789d95f7b897333cb.dmg";
    hash = "sha256-uo/kr9PAFREfbkXX9hpJJNT6OZDv3jnOuZgc2fwtSyM=";
    name = "GameHub_en_${finalAttrs.version}.dmg";
  };

  strictDeps = true;

  nativeBuildInputs = [
    undmg
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications" "$out/bin"
    mv GameHub.app "$out/Applications/"
    makeWrapper "$out/Applications/GameHub.app/Contents/MacOS/GameHub" "$out/bin/GameHub"

    runHook postInstall
  '';

  __structuredAttrs = true;
  sourceRoot = ".";
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Play mobile games natively on macOS";
    homepage = "https://www.gamemac.com/en/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ damidoug ];
    platforms = lib.platforms.darwin;
    mainProgram = "GameHub";
  };
})
