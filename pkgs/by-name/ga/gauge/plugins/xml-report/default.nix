{
  lib,
  makeGaugePlugin,
}:
makeGaugePlugin {
  pname = "xml-report";
  data = lib.importJSON ./data.json;
  releasePrefix = "xml-report-";
  repo = "getgauge/xml-report";

  meta = {
    description = "XML report generation plugin for Gauge";
    homepage = "https://github.com/getgauge/xml-report/";
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
