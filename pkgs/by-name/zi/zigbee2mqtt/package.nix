{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  nix-update-script,
  nixosTests,
  nodejs,
  npmHooks,
  pnpmConfigHook,
  pnpm_10,
  systemdMinimal,
  withSystemd ? lib.meta.availableOn stdenv.hostPlatform systemdMinimal,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "zigbee2mqtt";
  version = "2.12.1";

  src = fetchFromGitHub {
    owner = "Koenkk";
    repo = "zigbee2mqtt";
    tag = finalAttrs.version;
    hash = "sha256-DTL27AcPmAI5XEEHb2S74LYWm4f6kUASsTmQeGftDzM=";
  };

  nativeBuildInputs = [
    nodejs
    npmHooks.npmInstallHook
    pnpmConfigHook
    pnpm_10
  ];

  buildInputs = lib.optionals withSystemd [
    systemdMinimal
  ];

  buildPhase = ''
    runHook preBuild

    pnpm run build

    runHook postBuild
  '';

  dontNpmPrune = true;

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 4;
    hash = "sha256-RI6tz8pyqYg/L6wSc0Rt5ZqHT8aktReyVjNgISPqKRQ=";
    pnpm = pnpm_10;
  };

  passthru.tests.zigbee2mqtt = nixosTests.zigbee2mqtt;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Zigbee to MQTT bridge using zigbee-shepherd";

    longDescription = ''
      Allows you to use your Zigbee devices without the vendor's bridge or gateway.

      It bridges events and allows you to control your Zigbee devices via MQTT.
      In this way you can integrate your Zigbee devices with whatever smart home infrastructure you are using.
    '';

    homepage = "https://github.com/Koenkk/zigbee2mqtt";
    changelog = "https://github.com/Koenkk/zigbee2mqtt/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ hexa ];
    mainProgram = "zigbee2mqtt";
  };
})
