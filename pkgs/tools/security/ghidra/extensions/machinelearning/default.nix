{
  lib,
  buildGhidraExtension,
  ghidra,
}:

buildGhidraExtension {
  pname = "machinelearning";
  version = lib.getVersion ghidra;
  src = "${ghidra}/lib/ghidra/Extensions/Ghidra/${ghidra.distroPrefix}_MachineLearning.zip";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/ghidra/Ghidra/Extensions
    unzip -d $out/lib/ghidra/Ghidra/Extensions $src

    runHook postInstall
  '';

  # Built as part ghidra
  dontBuild = true;
  dontUnpack = true;

  meta = {
    inherit (ghidra.meta) homepage license;
    description = "Finds functions using ML";

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode # deps
    ];

    downloadPage = "https://github.com/NationalSecurityAgency/ghidra/tree/master/Ghidra/Extensions/MachineLearning";
  };
}
