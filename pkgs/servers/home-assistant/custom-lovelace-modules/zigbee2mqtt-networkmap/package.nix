{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  nix-update-script,
  nodejs,
  yarnBuildHook,
  yarnConfigHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zigbee2mqtt-networkmap";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "azuwis";
    repo = "zigbee2mqtt-networkmap";
    tag = "v${finalAttrs.version}";
    hash = "sha256-b1B8M2EP+lt7H3M+8tlgVCRWX43jeOr6a2XJT+cRI18=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    nodejs
  ];

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -v dist/zigbee2mqtt-networkmap.js $out/

    runHook postInstall
  '';

  dontFixup = true;

  offlineCache = fetchYarnDeps {
    inherit (finalAttrs) src;
    hash = "sha256-juql9gJX3NPOR0AVXejHC0XmRWwdtemMUCDS3iKM+wA=";
  };

  passthru.entrypoint = "zigbee2mqtt-networkmap.js";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Home Assistant Custom Card to show Zigbee2mqtt network map";
    homepage = "https://github.com/azuwis/zigbee2mqtt-networkmap";
    changelog = "https://github.com/azuwis/zigbee2mqtt-networkmap/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ azuwis ];
  };
})
