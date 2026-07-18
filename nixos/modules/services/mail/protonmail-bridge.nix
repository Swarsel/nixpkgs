{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.protonmail-bridge;
in
{
  options.services.protonmail-bridge = {
    enable = lib.mkEnableOption "protonmail bridge";
    package = lib.mkPackageOption pkgs "protonmail-bridge" { };

    logLevel = lib.mkOption {
      default = null;
      description = "Log level of the Proton Mail Bridge service. If set to null then the service uses it's default log level.";

      type = lib.types.nullOr (
        lib.types.enum [
          "panic"
          "fatal"
          "error"
          "warn"
          "info"
          "debug"
        ]
      );
    };

    path = lib.mkOption {
      default = [ ];
      description = "List of derivations to put in protonmail-bridge's path.";
      example = lib.literalExpression "with pkgs; [ pass gnome-keyring ]";
      type = lib.types.listOf lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.user.services.protonmail-bridge = {
      after = [ "graphical-session.target" ];
      description = "protonmail bridge";
      path = cfg.path;

      serviceConfig =
        let
          logLevel = lib.optionalString (cfg.logLevel != null) "--log-level ${cfg.logLevel}";
        in
        {
          ExecStart = "${lib.getExe cfg.package} --noninteractive ${logLevel}";
          Restart = "always";
        };

      wantedBy = [ "graphical-session.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ mzacho ];
}
