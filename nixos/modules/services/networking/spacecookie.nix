{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.spacecookie;

  spacecookieConfig = {
    listen = {
      inherit (cfg) port;
    };
  }
  // cfg.settings;

  format = pkgs.formats.json { };

  configFile = format.generate "spacecookie.json" spacecookieConfig;

in
{
  imports = [
    (mkRenamedOptionModule
      [ "services" "spacecookie" "root" ]
      [ "services" "spacecookie" "settings" "root" ]
    )
    (mkRenamedOptionModule
      [ "services" "spacecookie" "hostname" ]
      [ "services" "spacecookie" "settings" "hostname" ]
    )
  ];

  options = {

    services.spacecookie = {

      enable = mkEnableOption "spacecookie";

      package = mkPackageOption pkgs "spacecookie" {
        example = "haskellPackages.spacecookie";
      };

      address = mkOption {
        default = "[::]";

        description = ''
          Address to listen on. Must be in the
          `ListenStream=` syntax of
          {manpage}`systemd.socket(5)`.
        '';

        type = types.str;
      };

      openFirewall = mkOption {
        default = false;

        description = ''
          Whether to open the necessary port in the firewall for spacecookie.
        '';

        type = types.bool;
      };

      port = mkOption {
        default = 70;

        description = ''
          Port the gopher service should be exposed on.
        '';

        type = types.port;
      };

      settings = mkOption {
        description = ''
          Settings for spacecookie. The settings set here are
          directly translated to the spacecookie JSON config
          file. See
          [spacecookie.json(5)](https://sternenseemann.github.io/spacecookie/spacecookie.json.5.html)
          for explanations of all options.
        '';

        type = types.submodule {
          options.hostname = mkOption {
            default = "localhost";

            description = ''
              The hostname the service is reachable via. Clients
              will use this hostname for further requests after
              loading the initial gopher menu.
            '';

            type = types.str;
          };

          options.log = {
            enable = mkEnableOption "logging for spacecookie" // {
              default = true;
              example = false;
            };

            hide-ips = mkOption {
              default = true;

              description = ''
                If enabled, spacecookie will hide personal
                information of users like IP addresses from
                log output.
              '';

              type = types.bool;
            };

            hide-time = mkOption {
              # since we are starting with systemd anyways
              # we deviate from the default behavior here:
              # journald will add timestamps, so no need
              # to double up.
              default = true;

              description = ''
                If enabled, spacecookie will not print timestamps
                at the beginning of every log line.
              '';

              type = types.bool;
            };

            level = mkOption {
              default = "info";

              description = ''
                Log level for the spacecookie service.
              '';

              type = types.enum [
                "info"
                "warn"
                "error"
              ];
            };
          };

          options.root = mkOption {
            default = "/srv/gopher";

            description = ''
              The directory spacecookie should serve via gopher.
              Files in there need to be world-readable since
              the spacecookie service file sets
              `DynamicUser=true`.
            '';

            type = types.path;
          };

          freeformType = format.type;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !(cfg.settings ? user);

        message = ''
          spacecookie is started as a normal user, so the setuid
          feature doesn't work. If you want to run spacecookie as
          a specific user, set:
          systemd.services.spacecookie.serviceConfig = {
            DynamicUser = false;
            User = "youruser";
            Group = "yourgroup";
          }
        '';
      }
      {
        assertion = !(cfg.settings ? listen || cfg.settings ? port);

        message = ''
          The NixOS spacecookie module uses socket activation,
          so the listen options have no effect. Use the port
          and address options in services.spacecookie instead.
        '';
      }
    ];

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    systemd.services.spacecookie = {
      description = "Spacecookie Gopher Server";
      requires = [ "spacecookie.socket" ];

      serviceConfig = {
        CapabilityBoundingSet = "";
        DynamicUser = true;
        ExecStart = "${lib.getBin cfg.package}/bin/spacecookie ${configFile}";
        FileDescriptorStoreMax = 1;
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        # AF_UNIX for communication with systemd
        # AF_INET replaced by BindIPv6Only=both
        RestrictAddressFamilies = "AF_UNIX AF_INET6";
        RestrictRealtime = true;
        Type = "notify";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.sockets.spacecookie = {
      description = "Socket for the Spacecookie Gopher Server";
      listenStreams = [ "${cfg.address}:${toString cfg.port}" ];

      socketConfig = {
        BindIPv6Only = "both";
      };

      wantedBy = [ "sockets.target" ];
    };
  };
}
