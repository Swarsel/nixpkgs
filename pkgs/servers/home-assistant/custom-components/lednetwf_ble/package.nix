{
  lib,
  fetchFromGitHub,
  bleak,
  bleak-retry-connector,
  bluetooth-sensor-state-data,
  buildHomeAssistantComponent,
  nix-update-script,
}:
let
  version = "2.0.0";
in
buildHomeAssistantComponent {
  inherit version;

  src = fetchFromGitHub {
    owner = "8none1";
    repo = "lednetwf_ble";
    tag = "v${version}";
    hash = "sha256-Keb2Eph2DvS0zsg7wa30LrfqkmmccLl9okfdd0OTpqc=";
  };

  # Currently there are no tests run, so we skip
  doCheck = false;

  dependencies = [
    bluetooth-sensor-state-data
    bleak-retry-connector
    bleak
  ];

  domain = "lednetwf_ble";
  owner = "8none1";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Home Assistant custom integration for LEDnetWF devices";
    homepage = "https://github.com/8none1/lednetwf_ble";
    changelog = "https://github.com/8none1/lednetwf_ble/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kilyanni ];
  };
}
