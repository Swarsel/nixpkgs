{ config, lib, ... }:
let
  t = lib.types;
in
{
  options = {
    virtualisation.diskSize = lib.mkOption {
      default = if config.virtualisation.diskSizeAutoSupported then "auto" else 1024;
      defaultText = lib.literalExpression "if virtualisation.diskSizeAutoSupported then \"auto\" else 1024";

      description = ''
        The disk size in MiB (1024×1024 bytes) of the virtual machine.
      '';

      type = t.either (t.enum [ "auto" ]) t.ints.positive;
    };

    virtualisation.diskSizeAutoSupported = lib.mkOption {
      default = true;

      description = ''
        Whether the current image builder or vm runner supports `virtualisation.diskSize = "auto".`
      '';

      internal = true;
      type = t.bool;
    };
  };

  config =
    let
      inherit (config.virtualisation) diskSize diskSizeAutoSupported;
    in
    {
      assertions = [
        {
          assertion = diskSize != "auto" || diskSizeAutoSupported;
          message = "Setting virtualisation.diskSize to `auto` is not supported by the current image build or vm runner; use an explicit size.";
        }
      ];
    };
}
