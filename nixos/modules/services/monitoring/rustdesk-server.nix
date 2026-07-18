{
  config,
  lib,
  pkgs,
  ...
}:
let
  TCPPorts = [
    21115
    21116
    21117
    21118
    21119
  ];
  UDPPorts = [ 21116 ];
in
{
  imports = [
    (lib.mkRemovedOptionModule [
      "services"
      "rustdesk-server"
      "relayIP"
    ] "This option has been replaced by services.rustdesk-server.signal.relayHosts")
    (lib.mkRenamedOptionModule
      [ "services" "rustdesk-server" "extraRelayArgs" ]
      [ "services" "rustdesk-server" "relay" "extraArgs" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "rustdesk-server" "extraSignalArgs" ]
      [ "services" "rustdesk-server" "signal" "extraArgs" ]
    )
  ];

  options.services.rustdesk-server =
    with lib;
    with types;
    {
      enable = mkEnableOption "RustDesk, a remote access and remote control software, allowing maintenance of computers and other devices";
      package = mkPackageOption pkgs "rustdesk-server" { };

      openFirewall = mkOption {
        default = false;

        description = ''
          Open the connection ports.
          TCP (${lib.concatStringsSep ", " (map toString TCPPorts)})
          UDP (${lib.concatStringsSep ", " (map toString UDPPorts)})
        '';

        type = types.bool;
      };

      relay = {
        enable = mkOption {
          default = true;

          description = ''
            Whether to enable the RustDesk relay server.
          '';

          type = bool;
        };

        extraArgs = mkOption {
          default = [ ];

          description = ''
            A list of extra command line arguments to pass to the `hbbr` process.
          '';

          example = [
            "-k"
            "_"
          ];

          type = listOf str;
        };
      };

      signal = {
        enable = mkOption {
          default = true;

          description = ''
            Whether to enable the RustDesk signal server.
          '';

          type = bool;
        };

        extraArgs = mkOption {
          default = [ ];

          description = ''
            A list of extra command line arguments to pass to the `hbbs` process.
          '';

          example = [
            "-k"
            "_"
          ];

          type = listOf str;
        };

        relayHosts = mkOption {
          default = [ ];

          # reference: https://rustdesk.com/docs/en/self-host/rustdesk-server-pro/relay/
          description = ''
            The relay server IP addresses or DNS names of the RustDesk relay.
          '';

          type = listOf str;
        };

      };

    };

  config =
    let
      cfg = config.services.rustdesk-server;
      serviceDefaults = {
        enable = true;
        requiredBy = [ "rustdesk.target" ];

        serviceConfig = {
          DynamicUser = "yes";
          Environment = [ ];
          Group = "rustdesk";
          LockPersonality = true;
          PrivateDevices = true;
          PrivateMounts = true;
          PrivateUsers = true;
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          RestrictNamespaces = true;
          Slice = "system-rustdesk.slice";
          StateDirectory = "rustdesk";
          StateDirectoryMode = "0750";
          User = "rustdesk";
          WorkingDirectory = "/var/lib/rustdesk";
        };
      };
    in
    lib.mkIf cfg.enable {
      networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall TCPPorts;
      networking.firewall.allowedUDPPorts = lib.mkIf cfg.openFirewall UDPPorts;

      systemd.services.rustdesk-relay = lib.mkIf cfg.relay.enable (
        lib.mkMerge [
          serviceDefaults
          {
            serviceConfig.ExecStart = "${cfg.package}/bin/hbbr ${lib.escapeShellArgs cfg.relay.extraArgs}";
          }
        ]
      );

      systemd.services.rustdesk-signal =
        let
          relayArg = builtins.concatStringsSep ":" cfg.signal.relayHosts;
        in
        lib.mkIf cfg.signal.enable (
          lib.mkMerge [
            serviceDefaults
            {
              serviceConfig.ExecStart = "${cfg.package}/bin/hbbs --relay-servers ${relayArg} ${lib.escapeShellArgs cfg.signal.extraArgs}";
            }
          ]
        );

      systemd.slices.system-rustdesk = {
        enable = true;
        description = "RustDesk Remote Desktop Slice";
      };

      systemd.targets.rustdesk = {
        enable = true;
        after = [ "network.target" ];
        description = "Target designed to group RustDesk Signal & RustDesk Relay";
        wantedBy = [ "multi-user.target" ];
      };

      users.groups.rustdesk = { };

      users.users.rustdesk = {
        description = "System user for RustDesk";
        group = "rustdesk";
        isSystemUser = true;
      };
    };

  meta.maintainers = with lib.maintainers; [ ppom ];
}
