{
  lib,
  makeGaugePlugin,
}:
makeGaugePlugin {
  pname = "java";
  data = lib.importJSON ./data.json;
  releasePrefix = "gauge-java-";
  repo = "getgauge/gauge-java";

  meta = {
    description = "Gauge plugin that lets you write tests in Java";
    homepage = "https://github.com/getgauge/gauge-java/";
    license = lib.licenses.asl20;

    sourceProvenance = with lib.sourceTypes; [
      # Native binary written in go
      binaryNativeCode
      # Jar files
      binaryBytecode
    ];

    maintainers = [ ];

    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
}
