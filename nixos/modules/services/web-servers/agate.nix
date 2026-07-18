{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.agate;
in
{
  options = {
    services.agate = {
      enable = mkEnableOption "Agate Server";
      package = mkPackageOption pkgs "agate" { };

      addresses = mkOption {
        default = [ "0.0.0.0:1965" ];

        description = ''
          Addresses to listen on, IP:PORT, if you haven't disabled forwarding
          only set IPv4.
        '';

        type = types.listOf types.str;
      };

      certificatesDir = mkOption {
        default = "/var/lib/agate/certificates";
        description = "Root of the certificate directory.";
        type = types.path;
      };

      contentDir = mkOption {
        default = "/var/lib/agate/content";
        description = "Root of the content directory.";
        type = types.path;
      };

      extraArgs = mkOption {
        default = [ "" ];
        description = "Extra arguments to use running agate.";
        example = [ "--log-ip" ];
        type = types.listOf types.str;
      };

      hostnames = mkOption {
        default = [ ];

        description = ''
          Domain name of this Gemini server, enables checking hostname and port
          in requests. (multiple occurrences means basic vhosts)
        '';

        type = types.listOf types.str;
      };

      language = mkOption {
        default = null;
        description = "RFC 4646 Language code for text/gemini documents.";
        type = types.nullOr types.str;
      };

      onlyTls_1_3 = mkOption {
        default = false;
        description = "Only use TLSv1.3 (default also allows TLSv1.2).";
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable {
    # available for generating certs by hand
    # it can be a bit arduous with openssl
    environment.systemPackages = [ cfg.package ];

    systemd.services.agate = {
      after = [
        "network.target"
        "network-online.target"
      ];

      description = "Agate";

      script =
        let
          prefixKeyList =
            key: list:
            concatMap (v: [
              key
              v
            ]) list;
          addresses = prefixKeyList "--addr" cfg.addresses;
          hostnames = prefixKeyList "--hostname" cfg.hostnames;
        in
        ''
          exec ${cfg.package}/bin/agate ${
            escapeShellArgs (
              [
                "--content"
                "${cfg.contentDir}"
                "--certs"
                "${cfg.certificatesDir}"
              ]
              ++ addresses
              ++ (optionals (cfg.hostnames != [ ]) hostnames)
              ++ (optionals (cfg.language != null) [
                "--lang"
                cfg.language
              ])
              ++ (optionals cfg.onlyTls_1_3 [ "--only-tls13" ])
              ++ (optionals (cfg.extraArgs != [ ]) cfg.extraArgs)
            )
          }
        '';

      serviceConfig = {
        # Security options:
        AmbientCapabilities = "";
        CapabilityBoundingSet = "";
        # ProtectClock= adds DeviceAllow=char-rtc r
        DeviceAllow = "";
        DynamicUser = true;
        LockPersonality = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        Restart = "always";
        RestartSec = "5s";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        StateDirectory = "agate";
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";

        SystemCallFilter = [
          "@system-service"
          "~@cpu-emulation"
          "~@debug"
          "~@keyring"
          "~@memlock"
          "~@obsolete"
          "~@privileged"
          "~@setuid"
        ];
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };
}
