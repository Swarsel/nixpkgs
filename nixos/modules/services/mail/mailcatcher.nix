{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.mailcatcher;

  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    optionalString
    ;
in
{
  # interface

  options = {

    services.mailcatcher = {
      enable = mkEnableOption "MailCatcher, an SMTP server and web interface to locally test outbound emails";

      http.ip = mkOption {
        default = "127.0.0.1";
        description = "The ip address of the http server.";
        type = types.str;
      };

      http.path = mkOption {
        default = null;
        description = "Prefix to all HTTP paths.";
        example = "/mailcatcher";
        type = with types; nullOr str;
      };

      http.port = mkOption {
        default = 1080;
        description = "The port address of the http server.";
        type = types.port;
      };

      smtp.ip = mkOption {
        default = "127.0.0.1";
        description = "The ip address of the smtp server.";
        type = types.str;
      };

      smtp.port = mkOption {
        default = 1025;
        description = "The port address of the smtp server.";
        type = types.port;
      };
    };

  };

  # implementation

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.mailcatcher ];

    systemd.services.mailcatcher = {
      after = [ "network.target" ];
      description = "MailCatcher Service";

      serviceConfig = {
        AmbientCapabilities = optionalString (
          cfg.http.port < 1024 || cfg.smtp.port < 1024
        ) "cap_net_bind_service";

        DynamicUser = true;

        ExecStart =
          "${pkgs.mailcatcher}/bin/mailcatcher --foreground --no-quit --http-ip ${cfg.http.ip} --http-port ${toString cfg.http.port} --smtp-ip ${cfg.smtp.ip} --smtp-port ${toString cfg.smtp.port}"
          + optionalString (cfg.http.path != null) " --http-path ${cfg.http.path}";

        Restart = "always";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
