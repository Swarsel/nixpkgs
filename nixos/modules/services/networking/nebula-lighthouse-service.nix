{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) types;

  cfg = config.services.nebula-lighthouse-service;
  settingsFormat = pkgs.formats.yaml { };
in
{

  options.services.nebula-lighthouse-service = {
    enable = lib.mkEnableOption "nebula-lighthouse-service";

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration for nebula-lighthouse-service.
      '';

      example = {
        max-port = 65535;
        min-port = 49152;
        "webserver.ip" = "127.0.0.1";
        "webserver.port" = 8080;
      };

      type = settingsFormat.type;
    };

    user = lib.mkOption {
      default = "nebula-lighthouse";

      description = ''
        The user and group to run nebula-lighthouse-service as.
      '';

      example = "nebula-lighthouse";
      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."nebula-lighthouse-service/config.yaml".source =
      settingsFormat.generate "nebula-lighthouse-service-config.yaml" cfg.settings;

    services.nebula-lighthouse-service.settings = {
      max-port = lib.mkDefault 65535;
      min-port = lib.mkDefault 49152;
      "webserver.ip" = lib.mkDefault "127.0.0.1";
      "webserver.port" = lib.mkDefault 8080;
    };

    systemd.services.nebula-lighthouse-service = {
      after = [
        "basic.target"
        "network.target"
      ];

      description = "Run nebula-lighthouse-service";

      serviceConfig = {
        ExecStart = "${pkgs.nebula-lighthouse-service}/bin/nebula-lighthouse-service";
        Group = cfg.user;
        Restart = "always";
        StateDirectory = "nebula-lighthouse-service";
        Type = "exec";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "basic.target" ];
    };

    users.groups.${cfg.user} = { };

    users.users.${cfg.user} = {
      description = "nebula-lighthouse-service user";
      group = cfg.user;
      isSystemUser = true;
    };
  };

  meta.maintainers = with lib.maintainers; [
    bloominstrong
  ];
}
