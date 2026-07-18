{
  lib,
  makeGaugePlugin,
}:
makeGaugePlugin {
  pname = "html-report";
  data = lib.importJSON ./data.json;
  releasePrefix = "html-report-";
  repo = "getgauge/html-report";

  meta = {
    description = "HTML report generation plugin for Gauge";
    homepage = "https://github.com/getgauge/html-report/";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ ];

    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
}
