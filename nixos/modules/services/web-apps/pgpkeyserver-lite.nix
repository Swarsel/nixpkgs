{
  config,
  lib,
  pkgs,
  options,
  ...
}:

with lib;

let

  cfg = config.services.pgpkeyserver-lite;
  sksCfg = config.services.sks;
  sksOpt = options.services.sks;

  webPkg = cfg.package;

in

{

  options = {

    services.pgpkeyserver-lite = {

      enable = mkEnableOption "pgpkeyserver-lite on a nginx vHost proxying to a gpg keyserver";
      package = mkPackageOption pkgs "pgpkeyserver-lite" { };

      hkpAddress = mkOption {
        default = builtins.head sksCfg.hkpAddress;
        defaultText = literalExpression "head config.${sksOpt.hkpAddress}";

        description = ''
          Which IP address the sks-keyserver is listening on.
        '';

        type = types.str;
      };

      hkpPort = mkOption {
        default = sksCfg.hkpPort;
        defaultText = literalExpression "config.${sksOpt.hkpPort}";

        description = ''
          Which port the sks-keyserver is listening on.
        '';

        type = types.port;
      };

      hostname = mkOption {
        description = ''
          Which hostname to set the vHost to that is proxying to sks.
        '';

        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {

    services.nginx.enable = true;

    services.nginx.virtualHosts =
      let
        hkpPort = toString cfg.hkpPort;
      in
      {
        ${cfg.hostname} = {
          locations = {
            "/pks".extraConfig = ''
              proxy_pass         http://${cfg.hkpAddress}:${hkpPort};
              proxy_pass_header  Server;
              add_header         Via "1.1 ${cfg.hostname}";
            '';
          };

          root = webPkg;
        };
      };
  };
}
