{
  lib,
  fetchurl,
  nix-update-script,
  stdenvNoCC,
  undmg,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "lulu";
  version = "4.3.1";

  src = fetchurl {
    url = "https://github.com/objective-see/LuLu/releases/download/v${finalAttrs.version}/LuLu_${finalAttrs.version}.dmg";
    hash = "sha256-zANmUn8fQSMpX9EzKaCAMaZgr9JWB23asD5gdDZc75M=";
  };

  strictDeps = true;
  nativeBuildInputs = [ undmg ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications"
    cp -R LuLu.app "$out/Applications/LuLu.app"

    runHook postInstall
  '';

  __structuredAttrs = true;
  dontFixup = true; # Preserve upstream's notarized app bundle and system extension signature.

  unpackPhase = ''
    runHook preUnpack
    undmg "$src"
    runHook postUnpack
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Free open-source macOS firewall that alerts you to outgoing network connections";
    homepage = "https://objective-see.org/products/lulu.html";
    changelog = "https://github.com/objective-see/LuLu/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ philocalyst ];
    platforms = lib.platforms.darwin;
    mainProgram = "LuLu";
  };
})
