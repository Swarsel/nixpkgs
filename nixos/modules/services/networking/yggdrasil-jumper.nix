{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    escapeShellArgs
    filter
    hasPrefix
    makeBinPath
    mapAttrsToList
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    optional
    optionals
    ;
  format = pkgs.formats.toml { };
in
{
  options =
    let
      inherit (lib.types)
        bool
        enum
        lines
        listOf
        str
        ;
    in
    {
      services.yggdrasil-jumper = {
        enable = mkEnableOption "the Yggdrasil Jumper system service";
        package = mkPackageOption pkgs "yggdrasil-jumper" { };

        appendListenAddresses = mkOption {
          default = true;

          description = ''
            Append Yggdrasil router configuration with listeners on loopback
            addresses (`127.0.0.1`) and preselected ports to support peering
            using client-server protocols like `quic` and `tls`.

            See `Listen` option in Yggdrasil router configuration.
          '';

          type = bool;
        };

        detectWireguard = mkOption {
          default = true;

          description = ''
            Control whether `settings.wireguard = true` should automatically
            provide CAP_NET_ADMIN capability and make the necessary packages
            available to Yggdrasil Jumper service.
          '';

          type = bool;
        };

        extraArgs = mkOption {
          default = [ ];

          description = ''
            Extra command line arguments for Yggdrasil Jumper.
          '';

          type = listOf str;
        };

        extraConfig = mkOption {
          default = "";

          description = ''
            Configuration for Yggdrasil Jumper in plaintext.
          '';

          example = ''
            listen_port = 9999;
            whitelist = [
              "<IPv6 address of a remote node>"
            ];
          '';

          type = lines;
        };

        logLevel = mkOption {
          default = "info";

          description = ''
            Set logging verbosity for Yggdrasil Jumper.
          '';

          type = enum [
            "off"
            "error"
            "warn"
            "info"
            "debug"
            "trace"
          ];
        };

        retrieveListenAddresses = mkOption {
          default = true;

          description = ''
            Automatically retrieve listen addresses from the Yggdrasil router configuration.

            See `yggdrasil_listen` option in Yggdrasil Jumper configuration.
          '';

          type = bool;
        };

        settings = mkOption {
          default = { };

          description = ''
            Configuration for Yggdrasil Jumper as a Nix attribute set.
          '';

          example = {
            listen_port = 9999;
            whitelist = [ "<IPv6 address of a remote node>" ];
            wireguard = true;
          };

          type = format.type;
        };
      };
    };

  config =
    let
      cfg = config.services.yggdrasil-jumper;

      wg = cfg.detectWireguard && (cfg.settings ? wireguard) && cfg.settings.wireguard;
      wgExtraPkgs = optionals wg (
        with pkgs;
        [
          iproute2
          iptables
          wireguard-tools
          conntrack-tools
        ]
      );

      # Generate, concatenate and validate config file
      jumperSettings = format.generate "yggdrasil-jumper-settings" cfg.settings;
      jumperExtraConfig = pkgs.writeText "yggdrasil-jumper-extra-config" cfg.extraConfig;
      jumperConfig = pkgs.runCommand "yggdrasil-jumper-config" { } ''
        export PATH="${makeBinPath wgExtraPkgs}:$PATH"
        cat ${jumperSettings} ${jumperExtraConfig} \
          | tee $out \
          | ${cfg.package}/bin/yggdrasil-jumper --validate --config -
      '';
    in
    mkIf cfg.enable {
      assertions = [
        {
          assertion = config.services.yggdrasil.enable;
          message = "`services.yggdrasil.enable` must be true for `yggdrasil-jumper` to operate";
        }
      ];

      environment.systemPackages = [ cfg.package ];

      services.yggdrasil.settings.Listen =
        let
          # By default linux dynamically allocates ports in range 32768..60999
          # `sysctl net.ipv4.ip_local_port_range`
          # See: https://xkcd.com/221/
          prot_port = {
            "quic" = 11814;
            "tls" = 11814;
          };
        in
        mkIf (cfg.retrieveListenAddresses && cfg.appendListenAddresses) (
          mapAttrsToList (prot: port: "${prot}://127.0.0.1:${toString port}") prot_port
        );

      services.yggdrasil-jumper.settings = {
        yggdrasil_admin_listen = [ "unix:///run/yggdrasil/yggdrasil.sock" ];

        yggdrasil_listen = mkIf cfg.retrieveListenAddresses (
          filter (a: !hasPrefix "tcp://" a) config.services.yggdrasil.settings.Listen
        );
      };

      systemd.services.yggdrasil-jumper = {
        after = [ "yggdrasil.service" ];
        description = "Yggdrasil Jumper Service";
        path = wgExtraPkgs;

        serviceConfig = {
          AmbientCapabilities = optional wg "CAP_NET_ADMIN";
          CapabilityBoundingSet = optional wg "CAP_NET_ADMIN";
          DynamicUser = true;

          ExecStart = escapeShellArgs (
            [
              "${cfg.package}/bin/yggdrasil-jumper"
              "--loglevel"
              "${cfg.logLevel}"
              "--config"
              "${jumperConfig}"
            ]
            ++ cfg.extraArgs
          );

          # TODO: Remove this delay after support for proper startup notification lands in `yggdrasil-go`
          ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
          KillSignal = "SIGINT";
          MemoryDenyWriteExecute = true;
          ProtectControlGroups = true;
          ProtectHome = "tmpfs";

          RestrictAddressFamilies = [
            "AF_UNIX"
            "AF_INET"
            "AF_INET6"
          ]
          ++ optional wg "AF_NETLINK";

          RestrictNamespaces = true;
          RestrictRealtime = true;
          SystemCallArchitectures = "native";

          SystemCallFilter = [
            "@system-service"
            "~@privileged"
          ];

          User = "yggdrasil";
        };

        unitConfig.BindsTo = [ "yggdrasil.service" ];
        wantedBy = [ "multi-user.target" ];
      };
    };

  meta.maintainers = with lib.maintainers; [ one-d-wide ];
}
