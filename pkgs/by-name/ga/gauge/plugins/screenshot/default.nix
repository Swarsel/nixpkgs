{
  lib,
  makeGaugePlugin,
}:
makeGaugePlugin {
  pname = "screenshot";
  data = lib.importJSON ./data.json;
  releasePrefix = "screenshot-";
  repo = "getgauge/gauge_screenshot";

  meta = {
    description = "Gauge plugin to take screenshots";
    homepage = "https://github.com/getgauge/gauge_screenshot/";
    license = lib.licenses.gpl3;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];

    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
}
