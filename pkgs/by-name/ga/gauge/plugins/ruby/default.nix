{
  lib,
  makeGaugePlugin,
}:
makeGaugePlugin {
  pname = "ruby";
  data = lib.importJSON ./data.json;
  releasePrefix = "gauge-ruby-";
  repo = "getgauge/gauge-ruby";

  meta = {
    description = "Gauge plugin that lets you write tests in Ruby";
    homepage = "https://github.com/getgauge/gauge-ruby/";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];

    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
}
