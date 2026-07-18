{
  bc,
  coreutils,
  diffutils,
  findutils,
  writeShellApplication,
  firmwarePaths ? [
    "/run/current-system/firmware"
  ],
}:
writeShellApplication {
  name = "edido";

  runtimeInputs = [
    diffutils
    findutils
    coreutils
    bc
  ];

  text = ''
    FIRMWARE_PATH="''${FIRMWARE_PATH:-"${builtins.concatStringsSep ":" firmwarePaths}"}"
    ${builtins.readFile ./edido.sh}
  '';

  meta.description = "Tool to apply display configuration from `boot.kernelParams`";
}
