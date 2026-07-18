{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkOption mkPackageOption mkEnableOption;
  inherit (lib.lists) optional optionals;
  inherit (lib.strings)
    hasSuffix
    escapeShellArgs
    ;
  inherit (lib) types;
  cfg = config.services.vwifi;
in
{
  options = {
    services.vwifi =
      let
        mkOptionalPort =
          name:
          mkOption {
            default = null;

            description = ''
              The ${name} port. Set to null if we should leave it unset.
            '';

            type = with types; nullOr port;
          };
      in
      {
        package = mkPackageOption pkgs "vwifi" { };

        client = {
          enable = mkEnableOption "vwifi client";

          extraArgs = mkOption {
            default = [ ];

            description = ''
              Extra arguments to pass to vwifi-client. You can use this if you want to bring
              the radios up using vwifi-client instead of at boot.
            '';

            example = [
              "--number"
              "3"
            ];

            type = with types; listOf str;
          };

          serverAddress = mkOption {
            default = null;

            description = ''
              The address of the server. If set to null, will try to use the vsock protocol.
              Note that this assumes that the server is spawned on the host and passed through to
              QEMU, with something like:

              -device vhost-vsock-pci,id=vwifi0,guest-cid=42
            '';

            type = with types; nullOr str;
          };

          serverPort = mkOptionalPort "server port";
          spy = mkEnableOption "spy mode, useful for wireless monitors";
        };

        module = {
          enable = mkEnableOption "mac80211_hwsim module";

          macPrefix = mkOption {
            default = "74:F8:F6";

            description = ''
              The prefix for MAC addresses to use, without the trailing ':'.
              If one radio is created, you can specify the whole MAC address here.
              The default is defined in vwifi/src/config.h.
            '';

            type = types.strMatching "^(([0-9A-Fa-f]{2}:){0,5}[0-9A-Fa-f]{2})$";
          };

          numRadios = mkOption {
            default = 1;
            description = "The number of virtual radio interfaces to create.";
            type = types.int;
          };
        };

        server = {
          enable = mkEnableOption "vwifi server";

          extraArgs = mkOption {
            default = [ ];

            description = ''
              Extra arguments to pass to vwifi-server. You can use this for things including
              changing the ports or inducing packet loss.
            '';

            example = [ "--lost-packets" ];
            type = with types; listOf str;
          };

          openFirewall = mkEnableOption "opening the firewall for the TCP and spy ports";

          ports = {
            control = mkOptionalPort "control interface";
            spy = mkOptionalPort "spy interface";
            tcp = mkOptionalPort "TCP server";
            vhost = mkOptionalPort "vhost";
          };

          vsock.enable = mkEnableOption "vsock kernel module";
        };
      };
  };

  config = mkMerge [
    (mkIf cfg.module.enable {
      assertions = [
        {
          assertion = !(hasSuffix ":" cfg.module.macPrefix);

          message = ''
            services.vwifi.module.macPrefix should not have a trailing ":".
          '';
        }
      ];

      boot.extraModprobeConfig = ''
        # We'll add more radios using vwifi-add-interfaces in the systemd unit.
        options mac80211_hwsim radios=0
      '';

      boot.kernelModules = [
        "mac80211_hwsim"
      ];

      systemd.services.vwifi-add-interfaces = mkIf (cfg.module.numRadios > 0) {
        description = "vwifi interface bringup";

        serviceConfig = {
          ExecStart =
            let
              args = [
                (toString cfg.module.numRadios)
                cfg.module.macPrefix
              ];
            in
            "${cfg.package}/bin/vwifi-add-interfaces ${escapeShellArgs args}";

          Type = "oneshot";
        };

        wantedBy = [ "network-pre.target" ];
      };
    })
    (mkIf cfg.client.enable {
      systemd.services.vwifi-client =
        let
          clientArgs =
            optional cfg.client.spy "--spy"
            ++ optional (cfg.client.serverAddress != null) cfg.client.serverAddress
            ++ optionals (cfg.client.serverPort != null) [
              "--port"
              cfg.client.serverPort
            ]
            ++ cfg.client.extraArgs;
        in
        rec {
          after = [ "network.target" ];
          description = "vwifi client";
          requires = after;

          serviceConfig = {
            ExecStart = "${cfg.package}/bin/vwifi-client ${escapeShellArgs clientArgs}";
          };

          wantedBy = [ "multi-user.target" ];
        };
    })
    (mkIf cfg.server.enable {
      boot.kernelModules = mkIf cfg.server.vsock.enable [
        "vhost_vsock"
      ];

      networking.firewall.allowedTCPPorts = mkIf cfg.server.openFirewall (
        optional (cfg.server.ports.tcp != null) cfg.server.ports.tcp
        ++ optional (cfg.server.ports.spy != null) cfg.server.ports.spy
      );

      systemd.services.vwifi-server =
        let
          serverArgs =
            optionals (cfg.server.ports.vhost != null) [
              "--port-vhost"
              (toString cfg.server.ports.vhost)
            ]
            ++ optionals (cfg.server.ports.tcp != null) [
              "--port-tcp"
              (toString cfg.server.ports.tcp)
            ]
            ++ optionals (cfg.server.ports.spy != null) [
              "--port-spy"
              (toString cfg.server.ports.spy)
            ]
            ++ optionals (cfg.server.ports.control != null) [
              "--port-ctrl"
              (toString cfg.server.ports.control)
            ]
            ++ cfg.server.extraArgs;
        in
        rec {
          after = [ "network.target" ];
          description = "vwifi server";
          requires = after;

          serviceConfig = {
            ExecStart = "${cfg.package}/bin/vwifi-server ${escapeShellArgs serverArgs}";
          };

          wantedBy = [ "multi-user.target" ];
        };
    })
  ];

  meta.maintainers = with lib.maintainers; [ numinit ];
}
