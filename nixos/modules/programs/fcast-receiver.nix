{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.fcast-receiver;
in
{
  options.programs.fcast-receiver = {
    enable = lib.mkEnableOption "FCast Receiver";
    package = lib.mkPackageOption pkgs "fcast-receiver" { };

    openFirewall = lib.mkOption {
      default = false;

      description = ''
        Open ports needed for the functionality of the program.
      '';

      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ 46899 ];
    };
  };

  meta = {
    maintainers = pkgs.fcast-receiver.meta.maintainers;
  };
}
