{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.podgrab;

  stateDir = "/var/lib/podgrab";
in
{
  options.services.podgrab = with lib; {
    enable = mkEnableOption "Podgrab, a self-hosted podcast manager";

    dataDirectory = mkOption {
      default = "${stateDir}/data";
      description = "Directory to store downloads.";
      example = "/mnt/podcasts";
      type = types.path;
    };

    group = mkOption {
      default = "podgrab";
      description = "Group under which Podgrab runs, and which owns the download directory.";
      type = types.str;
    };

    passwordFile = mkOption {
      default = null;

      description = ''
        The path to a file containing the PASSWORD environment variable
        definition for Podgrab's authentication.
      '';

      example = "/run/secrets/password.env";
      type = with types; nullOr str;
    };

    port = mkOption {
      default = 8080;
      description = "The port on which Podgrab will listen for incoming HTTP traffic.";
      example = 4242;
      type = types.port;
    };

    user = mkOption {
      default = "podgrab";
      description = "User under which Podgrab runs, and which owns the download directory.";
      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.podgrab = {
      description = "Podgrab podcast manager";

      environment = {
        CONFIG = "${stateDir}/config";
        DATA = cfg.dataDirectory;
        GIN_MODE = "release";
        PORT = toString cfg.port;
      };

      serviceConfig = {
        EnvironmentFile = lib.optionals (cfg.passwordFile != null) [
          cfg.passwordFile
        ];

        ExecStart = "${pkgs.podgrab}/bin/podgrab";
        Group = cfg.group;
        StateDirectory = [ "podgrab/config" ];
        User = cfg.user;
        WorkingDirectory = "${pkgs.podgrab}/share";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.settings."10-pyload" = {
      ${cfg.dataDirectory}.d = { inherit (cfg) user group; };
    };

    users.groups.podgrab = lib.mkIf (cfg.group == "podgrab") { };

    users.users.podgrab = lib.mkIf (cfg.user == "podgrab") {
      group = cfg.group;
      isSystemUser = true;
    };
  };

  meta.maintainers = with lib.maintainers; [ ambroisie ];
}
