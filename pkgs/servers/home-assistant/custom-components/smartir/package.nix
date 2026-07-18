{
  lib,
  fetchFromGitHub,
  aiofiles,
  buildHomeAssistantComponent,
  distutils,
  nix-update-script,
}:

buildHomeAssistantComponent rec {
  version = "1.18.1";

  src = fetchFromGitHub {
    owner = "smartHomeHub";
    repo = "SmartIR";
    tag = version;
    hash = "sha256-gi5xlBOY6ek5roQKNqL7I0jrmJNPrxHHwEqOB/n2Itk=";
  };

  postInstall = ''
    cp -r codes $out/custom_components/smartir/
  '';

  dependencies = [
    aiofiles
    distutils
  ];

  domain = "smartir";
  owner = "smartHomeHub";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Integration for Home Assistant to control climate, TV and fan devices via IR/RF controllers (Broadlink, Xiaomi, MQTT, LOOKin, ESPHome)";
    homepage = "https://github.com/smartHomeHub/SmartIR";
    changelog = "https://github.com/smartHomeHub/SmartIR/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ azuwis ];
  };
}
