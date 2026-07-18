{
  lib,
  fetchurl,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "v2ray-rules-dat";
  version = "202607092306";
  src = null;
  strictDeps = true;

  installPhase = ''
    runHook preInstall

    install -Dm444 ${finalAttrs.passthru.geoipDat} $out/share/v2ray/geoip.dat
    install -Dm444 ${finalAttrs.passthru.geositeDat} $out/share/v2ray/geosite.dat

    runHook postInstall
  '';

  __structuredAttrs = true;
  dontUnpack = true;

  passthru = {
    geoipDat = fetchurl {
      hash = "sha256-g3l3GfrMCS4hD4+ODl4LC9/gaskKOko9amqy14GpF64=";
      url = "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/${finalAttrs.version}/geoip.dat";
    };

    geositeDat = fetchurl {
      hash = "sha256-E1Vs8u0vkDtgXQNHJejL0Xenl/fYn5IE9npD2M0Js8o=";
      url = "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/${finalAttrs.version}/geosite.dat";
    };

    updateScript = ./update.sh;
  };

  meta = {
    description = "Enhanced edition of V2Ray rules dat files";
    homepage = "https://github.com/Loyalsoldier/v2ray-rules-dat";
    changelog = "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ nix-julia ];
  };
})
