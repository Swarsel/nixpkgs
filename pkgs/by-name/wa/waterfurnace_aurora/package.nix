{
  lib,
  bundlerApp,
  bundlerUpdateScript,
}:

bundlerApp {
  pname = "waterfurnace_aurora";

  exes = [
    "aurora_fetch"
    "aurora_mock"
    "aurora_monitor"
    "aurora_mqtt_bridge"
    "web_aid_tool"
  ];

  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript "waterfurnace_aurora";

  meta = {
    description = "Tools for communication with WaterFurnace Aurora control systems";
    homepage = "https://github.com/ccutrer/waterfurnace_aurora";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ majiir ];
    mainProgram = "aurora_mqtt_bridge";
  };
}
