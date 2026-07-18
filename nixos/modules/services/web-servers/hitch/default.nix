{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.hitch;
  ocspDir = lib.optionalString cfg.ocsp-stapling.enabled "/var/cache/hitch/ocsp";
  hitchConfig =
    with lib;
    pkgs.writeText "hitch.conf" (
      concatStringsSep "\n" [
        "backend = \"${cfg.backend}\""
        (concatMapStrings (s: "frontend = \"${s}\"\n") cfg.frontend)
        (concatMapStrings (s: "pem-file = \"${s}\"\n") cfg.pem-files)
        "ciphers = \"${cfg.ciphers}\""
        "ocsp-dir = \"${ocspDir}\""
        "user = \"${cfg.user}\""
        "group = \"${cfg.group}\""
        cfg.extraConfig
      ]
    );
in
with lib;
{
  options = {
    services.hitch = {
      enable = mkEnableOption "Hitch Server";

      backend = mkOption {
        description = ''
          The host and port Hitch connects to when receiving
          a connection in the form [HOST]:PORT
        '';

        type = types.str;
      };

      ciphers = mkOption {
        default = "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";
        description = "The list of ciphers to use";
        type = types.str;
      };

      extraConfig = mkOption {
        default = "";
        description = "Additional configuration lines";
        type = types.lines;
      };

      frontend = mkOption {
        apply = toList;
        default = "[127.0.0.1]:443";

        description = ''
          The port and interface of the listen endpoint in the
          form [HOST]:PORT[+CERT].
        '';

        type = types.either types.str (types.listOf types.str);
      };

      group = mkOption {
        default = "hitch";
        description = "The group to run as";
        type = types.str;
      };

      ocsp-stapling = {
        enabled = mkOption {
          default = true;
          description = "Whether to enable OCSP Stapling";
          type = types.bool;
        };
      };

      pem-files = mkOption {
        default = [ ];
        description = "PEM files to use";
        type = types.listOf types.path;
      };

      user = mkOption {
        default = "hitch";
        description = "The user to run as";
        type = types.str;
      };
    };

  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkgs.hitch ];

    systemd.services.hitch = {
      after = [ "network.target" ];
      description = "Hitch";

      preStart = ''
        ${pkgs.hitch}/sbin/hitch -t --config ${hitchConfig}
      ''
      + (optionalString cfg.ocsp-stapling.enabled ''
        mkdir -p ${ocspDir}
        chown -R hitch:hitch ${ocspDir}
      '');

      serviceConfig = {
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        ExecStart = "${pkgs.hitch}/sbin/hitch --daemon --config ${hitchConfig}";
        LimitNOFILE = 131072;
        Restart = "always";
        RestartSec = "5s";
        Type = "forking";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.hitch = { };

    users.users.hitch = {
      group = "hitch";
      isSystemUser = true;
    };
  };
}
