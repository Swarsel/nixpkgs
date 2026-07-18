{
  lib,
  buildEnv,
  plasticscm-client-core,
  plasticscm-client-gui,
}:
buildEnv {
  inherit (plasticscm-client-core) version;
  pname = "plasticscm-client-complete";
  name = "plasticscm-client-complete-${plasticscm-client-core.version}";

  paths = [
    plasticscm-client-core
    plasticscm-client-gui
  ];

  meta = {
    description = "SCM by Unity for game development";
    homepage = "https://www.plasticscm.com";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ musjj ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "plasticgui";
  };
}
