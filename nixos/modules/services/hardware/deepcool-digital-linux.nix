{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.hardware.deepcool-digital-linux;
in
{
  options.services.hardware.deepcool-digital-linux = {
    enable = lib.mkEnableOption "DeepCool Digital monitoring daemon";
    package = lib.mkPackageOption pkgs "deepcool-digital-linux" { };

    extraArgs = lib.mkOption {
      default = [ ];

      description = ''
        Extra command line arguments to be passed to the deepcool-digital-linux daemon.
      '';

      example = lib.literalExpression ''
        [
          # Change the update interval
          "--update 750"
          # Enable the alarm
          "--alarm"
        ]
      '';

      type = lib.types.listOf lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.deepcool-digital-linux = {
      description = "DeepCool Digital";

      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package} ${lib.escapeShellArgs cfg.extraArgs}";
        Restart = "always";
        StateDirectory = "deepcool-digital-linux";
        WorkingDirectory = "/var/lib/deepcool-digital-linux";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = [ lib.maintainers.NotAShelf ];
}
