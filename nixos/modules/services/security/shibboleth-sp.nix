{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.shibboleth-sp;
in
{
  options = {
    services.shibboleth-sp = {
      enable = lib.mkOption {
        default = false;
        description = "Whether to enable the shibboleth service";
        type = lib.types.bool;
      };

      configFile = lib.mkOption {
        description = "Path to shibboleth config file";
        example = lib.literalExpression ''"''${pkgs.shibboleth-sp}/etc/shibboleth/shibboleth2.xml"'';
        type = lib.types.path;
      };

      fastcgi.enable = lib.mkOption {
        default = false;
        description = "Whether to include the shibauthorizer and shibresponder FastCGI processes";
        type = lib.types.bool;
      };

      fastcgi.shibAuthorizerPort = lib.mkOption {
        default = 9100;
        description = "Port for shibauthorizer FastCGI process to bind to";
        type = lib.types.port;
      };

      fastcgi.shibResponderPort = lib.mkOption {
        default = 9101;
        description = "Port for shibauthorizer FastCGI process to bind to";
        type = lib.types.port;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.shibauthorizer = lib.mkIf cfg.fastcgi.enable {
      after = [ "network.target" ];
      description = "Provides SSO through Shibboleth via FastCGI";
      environment.SHIBSP_CONFIG = "${cfg.configFile}";
      path = [ "${pkgs.spawn_fcgi}" ];

      serviceConfig = {
        ExecStart = "${pkgs.spawn_fcgi}/bin/spawn-fcgi -n -p ${toString cfg.fastcgi.shibAuthorizerPort} ${pkgs.shibboleth-sp}/lib/shibboleth/shibauthorizer";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.shibboleth-sp = {
      after = lib.optionals cfg.fastcgi.enable [
        "shibresponder.service"
        "shibauthorizer.service"
      ];

      description = "Provides SSO and federation for web applications";

      serviceConfig = {
        ExecStart = "${pkgs.shibboleth-sp}/bin/shibd -F -d ${pkgs.shibboleth-sp} -c ${cfg.configFile}";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.shibresponder = lib.mkIf cfg.fastcgi.enable {
      after = [ "network.target" ];
      description = "Provides SSO through Shibboleth via FastCGI";
      environment.SHIBSP_CONFIG = "${cfg.configFile}";
      path = [ "${pkgs.spawn_fcgi}" ];

      serviceConfig = {
        ExecStart = "${pkgs.spawn_fcgi}/bin/spawn-fcgi -n -p ${toString cfg.fastcgi.shibResponderPort} ${pkgs.shibboleth-sp}/lib/shibboleth/shibresponder";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = [ ];
}
