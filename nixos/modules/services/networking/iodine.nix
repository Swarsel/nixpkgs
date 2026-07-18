# NixOS module for iodine, ip over dns daemon
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.iodine;

  iodinedUser = "iodined";

  # is this path made unreadable by ProtectHome = true ?
  isProtected = x: lib.hasPrefix "/root" x || lib.hasPrefix "/home" x;
in
{
  imports = [
    (lib.mkRenamedOptionModule
      [ "services" "iodined" "enable" ]
      [ "services" "iodine" "server" "enable" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "iodined" "domain" ]
      [ "services" "iodine" "server" "domain" ]
    )
    (lib.mkRenamedOptionModule [ "services" "iodined" "ip" ] [ "services" "iodine" "server" "ip" ])
    (lib.mkRenamedOptionModule
      [ "services" "iodined" "extraConfig" ]
      [ "services" "iodine" "server" "extraConfig" ]
    )
    (lib.mkRemovedOptionModule [ "services" "iodined" "client" ] "")
  ];

  ### configuration

  options = {

    services.iodine = {
      clients = lib.mkOption {
        default = { };

        description = ''
          Each attribute of this option defines a systemd service that
          runs iodine. Many or none may be defined.
          The name of each service is
          `iodine-«name»`
          where «name» is the name of the
          corresponding attribute name.
        '';

        example = lib.literalExpression ''
          {
            foo = {
              server = "tunnel.mdomain.com";
              relay = "8.8.8.8";
              extraConfig = "-v";
            }
          }
        '';

        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              extraConfig = lib.mkOption {
                default = "";
                description = "Additional command line parameters";
                example = "-l 192.168.1.10 -p 23";
                type = lib.types.str;
              };

              passwordFile = lib.mkOption {
                default = "";
                description = "Path to a file containing the password.";
                type = lib.types.str;
              };

              relay = lib.mkOption {
                default = "";
                description = "DNS server to use as an intermediate relay to the iodined server";
                example = "8.8.8.8";
                type = lib.types.str;
              };

              server = lib.mkOption {
                default = "";
                description = "Hostname of server running iodined";
                example = "tunnel.mydomain.com";
                type = lib.types.str;
              };
            };
          }
        );
      };

      server = {
        enable = lib.mkOption {
          default = false;
          description = "enable iodined server";
          type = lib.types.bool;
        };

        domain = lib.mkOption {
          default = "";
          description = "Domain or subdomain of which nameservers point to us";
          example = "tunnel.mydomain.com";
          type = lib.types.str;
        };

        extraConfig = lib.mkOption {
          default = "";
          description = "Additional command line parameters";
          example = "-l 192.168.1.10 -p 23";
          type = lib.types.str;
        };

        ip = lib.mkOption {
          default = "";
          description = "The assigned ip address or ip range";
          example = "172.16.10.1/24";
          type = lib.types.str;
        };

        passwordFile = lib.mkOption {
          default = "";
          description = "File that contains password";
          type = lib.types.str;
        };
      };

    };
  };

  ### implementation

  config = lib.mkIf (cfg.server.enable || cfg.clients != { }) {
    boot.kernelModules = [ "tun" ];
    environment.systemPackages = [ pkgs.iodine ];

    systemd.services =
      let
        createIodineClientService = name: cfg: {
          after = [ "network.target" ];
          description = "iodine client - ${name}";

          script = "exec ${pkgs.iodine}/bin/iodine -f -u ${iodinedUser} ${cfg.extraConfig} ${
            lib.optionalString (cfg.passwordFile != "") "< \"${toString cfg.passwordFile}\""
          } ${cfg.relay} ${cfg.server}";

          serviceConfig = {
            # Misc.
            LockPersonality = true;
            MemoryDenyWriteExecute = true;
            # Caps
            NoNewPrivileges = true;
            PrivateDevices = false;
            PrivateMounts = true;
            PrivateTmp = true;
            ProtectControlGroups = true;
            ProtectHome = if isProtected cfg.passwordFile then "read-only" else "true";
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            # hardening :
            # Filesystem access
            ProtectSystem = "strict";
            ReadWritePaths = "/dev/net/tun";
            Restart = "always";
            RestartSec = "30s";
            RestrictRealtime = true;
          };

          wantedBy = [ "multi-user.target" ];
        };
      in
      lib.listToAttrs (
        lib.mapAttrsToList (
          name: value: lib.nameValuePair "iodine-${name}" (createIodineClientService name value)
        ) cfg.clients
      )
      // {
        iodined = lib.mkIf (cfg.server.enable) {
          after = [ "network.target" ];
          description = "iodine, ip over dns server daemon";

          script = "exec ${pkgs.iodine}/bin/iodined -f -u ${iodinedUser} ${cfg.server.extraConfig} ${
            lib.optionalString (cfg.server.passwordFile != "") "< \"${toString cfg.server.passwordFile}\""
          } ${cfg.server.ip} ${cfg.server.domain}";

          serviceConfig = {
            # Misc.
            LockPersonality = true;
            MemoryDenyWriteExecute = true;
            # Caps
            NoNewPrivileges = true;
            PrivateDevices = false;
            PrivateMounts = true;
            PrivateTmp = true;
            ProtectControlGroups = true;
            ProtectHome = if isProtected cfg.server.passwordFile then "read-only" else "true";
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            # Filesystem access
            ProtectSystem = "strict";
            ReadWritePaths = "/dev/net/tun";
            RestrictRealtime = true;
          };

          wantedBy = [ "multi-user.target" ];
        };
      };

    users.groups.iodined.gid = config.ids.gids.iodined;

    users.users.${iodinedUser} = {
      description = "Iodine daemon user";
      group = "iodined";
      uid = config.ids.uids.iodined;
    };
  };
}
