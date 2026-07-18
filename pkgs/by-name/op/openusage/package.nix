{
  lib,
  fetchurl,
  nix-update-script,
  stdenvNoCC,
  undmg,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "openusage";
  version = "0.6.13";

  # if is aarch64 download aarch64, otherwise intel
  src =
    if stdenvNoCC.hostPlatform.isAarch64 then
      fetchurl {
        url = "https://github.com/robinebers/openusage/releases/download/v${finalAttrs.version}/OpenUsage_${finalAttrs.version}_aarch64.dmg";
        hash = "sha256-Zfv1VAJSDHFdo2R9KgZ3TN/gu2Ua9Uleq5wNXrBBEH4=";
      }
    else if stdenvNoCC.hostPlatform.isx86_64 then
      fetchurl {
        url = "https://github.com/robinebers/openusage/releases/download/v${finalAttrs.version}/OpenUsage_${finalAttrs.version}_x64.dmg";
        hash = "sha256-tllecJOGNUDG3GwQhjeRaNrTHVK2GPzstfiT/GanZmM=";
      }
    else
      throw "Unsupported architecture";

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r "OpenUsage.app" $out/Applications/

    runHook postInstall
  '';

  dontBuild = true;
  dontFixup = true;
  sourceRoot = ".";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Burning through your subscriptions too fast? Paying for stuff you never use? Stop guessing. OpenUsage is free and open source.";
    homepage = "https://www.openusage.ai/";
    changelog = "https://github.com/robinebers/openusage/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ myzel394 ];
    platforms = lib.platforms.darwin;
  };
})
