{
  lib,
  stdenv,
  gauge-unwrapped,
  makeGaugePlugin,
}:

makeGaugePlugin {
  pname = "dotnet";
  buildInputs = [ (lib.getLib stdenv.cc.cc) ];
  data = lib.importJSON ./data.json;
  isCrossArch = true;
  releasePrefix = "gauge-dotnet-";
  repo = "getgauge/gauge-dotnet";

  meta = {
    inherit (gauge-unwrapped.meta) platforms;
    description = "Gauge plugin that lets you write tests in C#";
    homepage = "https://github.com/getgauge/gauge-dotnet/";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = [ ];
  };
}
