{
  lib,
  makeGaugePlugin,
}:
makeGaugePlugin {
  pname = "go";
  data = lib.importJSON ./data.json;
  releasePrefix = "gauge-go-";
  repo = "getgauge-contrib/gauge-go";

  meta = {
    description = "Gauge plugin that lets you write tests in Go";
    homepage = "https://github.com/getgauge-contrib/gauge-go";
    license = lib.licenses.gpl3;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ ];

    platforms = [
      "aarch64-darwin"
      "x86_64-linux"
    ];
  };
}
