{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.whoogle-search;
in
{
  options = {
    services.whoogle-search = {
      enable = lib.mkEnableOption "Whoogle, a metasearch engine";

      extraEnv = lib.mkOption {
        default = { };

        description = ''
          Extra environment variables to pass to Whoogle, see
          https://github.com/benbusby/whoogle-search?tab=readme-ov-file#environment-variables
        '';

        type = with lib.types; attrsOf str;
      };

      listenAddress = lib.mkOption {
        default = "127.0.0.1";
        description = "Address to listen on for the web interface.";
        type = lib.types.str;
      };

      port = lib.mkOption {
        default = 5000;
        description = "Port to listen on.";
        type = lib.types.port;
      };
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.services.whoogle-search = {
      description = "Whoogle Search";

      environment = {
        CONFIG_VOLUME = "/var/lib/whoogle-search";
      }
      // cfg.extraEnv;

      path = [ pkgs.whoogle-search ];

      serviceConfig = {
        DynamicUser = true;
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";

        ExecStart =
          "${lib.getExe pkgs.whoogle-search}"
          + " --host '${cfg.listenAddress}'"
          + " --port '${toString cfg.port}'";

        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = true;
        Restart = "on-failure";
        RestartSec = "5s";
        StateDirectory = "whoogle-search";
        StateDirectoryMode = "0750";
        Type = "simple";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ malte-v ];
}
