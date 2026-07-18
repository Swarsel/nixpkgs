{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  pymodbus,
}:

buildHomeAssistantComponent rec {
  version = "2026.07.1";

  src = fetchFromGitHub {
    owner = "wills106";
    repo = "homeassistant-solax-modbus";
    tag = version;
    hash = "sha256-7/Wprn5PJhfnmSHenPFrQY3c1EBdmzqyH8ZclAmDwoI=";
  };

  dependencies = [ pymodbus ];
  domain = "solax_modbus";
  owner = "wills106";

  meta = {
    description = "SolaX Power Modbus custom_component for Home Assistant (Supports some Ginlong Solis, Growatt, Sofar Solar, TIGO TSI & Qcells Q.Volt Hyb)";
    homepage = "https://github.com/wills106/homeassistant-solax-modbus";
    changelog = "https://github.com/wills106/homeassistant-solax-modbus/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ Luflosi ];
  };
}
