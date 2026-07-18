{
  runtimeShell,
  symlinkJoin,
  writeShellScriptBin,
}:

{ emulator, rom }:

assert emulator.version == rom.version;

let
  runScript = writeShellScriptBin "run-x16" ''
    defaultRom="${rom}/share/x16-rom/rom.bin"
    exec "${emulator}/bin/x16emu" -rom $defaultRom "$@"
  '';
in
symlinkJoin {
  inherit (emulator) version;
  pname = "run-x16";

  paths = [
    emulator
    rom
    runScript
  ];
}
