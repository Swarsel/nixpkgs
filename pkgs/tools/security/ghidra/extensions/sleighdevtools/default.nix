{
  lib,
  buildGhidraExtension,
  ghidra,
  python3,
}:

buildGhidraExtension {
  pname = "sleighdevtools";
  version = lib.getVersion ghidra;
  src = "${ghidra}/lib/ghidra/Extensions/Ghidra/${ghidra.distroPrefix}_SleighDevTools.zip";
  buildInputs = [ python3 ];

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
    description = "Sleigh language development tools including external disassembler capabilities";

    longDescription = ''
      Sleigh language development tools including external disassembler capabilities.
      The GnuDisassembler extension may be also be required as a disassembly provider.
    '';

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode # deps
    ];

    downloadPage = "https://github.com/NationalSecurityAgency/ghidra/tree/master/Ghidra/Extensions/SleighDevTools";
  };
}
