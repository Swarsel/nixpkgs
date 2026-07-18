{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.tailscale;
  isNetworkd = config.networking.useNetworkd;
in
{
  options.services.tailscale = {
    enable = mkEnableOption "Tailscale client daemon";
    package = lib.mkPackageOption pkgs "tailscale" { };

    authKeyFile = mkOption {
      default = null;

      description = ''
        A file containing the auth key.
        Tailscale will be automatically started if provided.

        Services that bind to Tailscale IPs should order using {option}`systemd.services.<name>.after` `tailscaled-autoconnect.service`.
      '';

      example = "/run/secrets/tailscale_key";
      type = types.nullOr types.path;
    };

    authKeyParameters = mkOption {
      default = { };

      description = ''
        Extra parameters to pass after the auth key.
        See <https://tailscale.com/kb/1215/oauth-clients#registering-new-nodes-using-oauth-credentials>
      '';

      type = types.submodule {
        options = {
          baseURL = mkOption {
            default = null;
            description = "Base URL for the Tailscale API.";
            type = types.nullOr types.str;
          };

          ephemeral = mkOption {
            default = null;
            description = "Whether to register as an ephemeral node.";
            type = types.nullOr types.bool;
          };

          preauthorized = mkOption {
            default = null;
            description = "Whether to skip manual device approval.";
            type = types.nullOr types.bool;
          };
        };
      };
    };

    disableTaildrop = mkOption {
      default = false;
      description = "Whether to disable the Taildrop feature for sending files between nodes.";
      type = types.bool;
    };

    disableUpstreamLogging = mkOption {
      default = false;
      description = "Whether to disable Tailscaled from sending debug logging upstream.";
      type = types.bool;
    };

    extraDaemonFlags = mkOption {
      default = [ ];
      description = "Extra flags to pass to {command}`tailscaled`.";
      example = [ "--no-logs-no-support" ];
      type = types.listOf types.str;
    };

    extraSetFlags = mkOption {
      default = [ ];
      description = "Extra flags to pass to {command}`tailscale set`.";
      example = [ "--advertise-exit-node" ];
      type = types.listOf types.str;
    };

    extraUpFlags = mkOption {
      default = [ ];

      description = ''
        Extra flags to pass to {command}`tailscale up`. Only applied if {option}`services.tailscale.authKeyFile` is specified.
      '';

      example = [ "--ssh" ];
      type = types.listOf types.str;
    };

    interfaceName = mkOption {
      default = "tailscale0";
      description = ''The interface name for tunnel traffic. Use "userspace-networking" (beta) to not use TUN.'';
      type = types.str;
    };

    openFirewall = mkOption {
      default = false;
      description = "Whether to open the firewall for the specified port.";
      type = types.bool;
    };

    permitCertUid = mkOption {
      default = null;
      description = "Username or user ID of the user allowed to to fetch Tailscale TLS certificates for the node.";
      type = types.nullOr types.nonEmptyStr;
    };

    port = mkOption {
      default = 41641;
      description = "The port to listen on for tunnel traffic (0=autoselect).";
      type = types.port;
    };

    useRoutingFeatures = mkOption {
      default = "none";

      description = ''
        Enables settings required for Tailscale's routing features like subnet routers and exit nodes.

        To use these these features, you will still need to call `sudo tailscale up` with the relevant flags like `--advertise-exit-node` and `--exit-node`.

        When set to `client` or `both`, reverse path filtering will be set to loose instead of strict.
        When set to `server` or `both`, IP forwarding will be enabled.
      '';

      example = "server";

      type = types.enum [
        "none"
        "client"
        "server"
        "both"
      ];
    };
  };

  config = mkIf cfg.enable {
    boot.kernel.sysctl = mkIf (cfg.useRoutingFeatures == "server" || cfg.useRoutingFeatures == "both") {
      "net.ipv4.conf.all.forwarding" = mkOverride 97 true;
      "net.ipv6.conf.all.forwarding" = mkOverride 97 true;
    };

    environment.systemPackages = [ cfg.package ]; # for the CLI
    networking.dhcpcd.denyInterfaces = [ cfg.interfaceName ];
    networking.firewall.allowedUDPPorts = mkIf cfg.openFirewall [ cfg.port ];

    networking.firewall.checkReversePath = mkIf (
      cfg.useRoutingFeatures == "client" || cfg.useRoutingFeatures == "both"
    ) "loose";

    systemd.network.networks."50-tailscale" = mkIf isNetworkd {
      linkConfig = {
        ActivationPolicy = "manual";
        Unmanaged = true;
      };

      matchConfig = {
        Name = cfg.interfaceName;
      };
    };

    systemd.packages = [ cfg.package ];

    systemd.services.tailscaled = {
      after = lib.mkIf (config.networking.networkmanager.enable) [ "NetworkManager-wait-online.service" ];

      path = [
        (dirOf config.security.wrapperDir) # for `su` to use taildrive with correct access rights
        pkgs.procps # for collecting running services (opt-in feature)
        pkgs.getent # for `getent` to look up user shells
        pkgs.kmod # required to pass tailscale's v6nat check
      ]
      ++ lib.optional config.networking.resolvconf.enable config.networking.resolvconf.package;

      serviceConfig.Environment = [
        "PORT=${toString cfg.port}"
        ''"FLAGS=--tun ${lib.escapeShellArg cfg.interfaceName} ${lib.concatStringsSep " " cfg.extraDaemonFlags}"''
      ]
      ++ (lib.optionals (cfg.permitCertUid != null) [
        "TS_PERMIT_CERT_UID=${cfg.permitCertUid}"
      ])
      ++ (lib.optionals (cfg.disableTaildrop) [
        "TS_DISABLE_TAILDROP=true"
      ])
      ++ (lib.optionals (cfg.disableUpstreamLogging) [
        "TS_NO_LOGS_NO_SUPPORT=true"
      ]);

      # Restart tailscaled with a single `systemctl restart` at the
      # end of activation, rather than a `stop` followed by a later
      # `start`. Activation over Tailscale can hang for tens of
      # seconds in the stop+start setup, if the activation script has
      # a significant delay between the stop and start phases
      # (e.g. script blocked on another unit with a slow shutdown).
      #
      # Tailscale is aware of the correctness tradeoff involved, and
      # already makes its upstream systemd unit robust against unit
      # version mismatches on restart for compatibility with other
      # linux distros.
      stopIfChanged = false;
      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.tailscaled-autoconnect = mkIf (cfg.authKeyFile != null) {
      after = [ "tailscaled.service" ];
      enableStrictShellChecks = true;

      path = [
        cfg.package
        pkgs.jq
      ];

      script =
        let
          paramToString = v: if (builtins.isBool v) then (lib.boolToString v) else (toString v);
          params = lib.pipe cfg.authKeyParameters [
            (lib.filterAttrs (_: v: v != null))
            (lib.mapAttrsToList (k: v: "${k}=${paramToString v}"))
            (builtins.concatStringsSep "&")
            (params: if params != "" then "?${params}" else "")
          ];
        in
        # bash
        ''
          getState() {
            tailscale status --json --peers=false | jq -r '.BackendState'
          }

          lastState=""
          while state="$(getState)"; do
            if [[ "$state" != "$lastState" ]]; then
              # https://github.com/tailscale/tailscale/blob/v1.72.1/ipn/backend.go#L24-L32
              case "$state" in
                NeedsLogin|NeedsMachineAuth|Stopped)
                  echo "Server needs authentication, sending auth key"
                  tailscale up --auth-key "$(cat ${cfg.authKeyFile})${params}" ${escapeShellArgs cfg.extraUpFlags}
                  ;;
                Running)
                  echo "Tailscale is running"
                  systemd-notify --ready
                  exit 0
                  ;;
                *)
                  echo "Waiting for Tailscale State = Running or systemd timeout"
                  ;;
              esac
              echo "State = $state"
            fi
            lastState="$state"
            sleep .5
          done
        '';

      serviceConfig = {
        Type = "notify";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "tailscaled.service" ];
    };

    systemd.services.tailscaled-set = mkIf (cfg.extraSetFlags != [ ]) {
      after = [
        "tailscaled.service"
        "tailscaled-autoconnect.service"
      ];

      script = ''
        ${lib.getExe cfg.package} set ${escapeShellArgs cfg.extraSetFlags}
      '';

      serviceConfig = {
        Type = "oneshot";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "tailscaled.service" ];
    };
  };

  meta.maintainers = with maintainers; [
    mbaillie
    mfrw
  ];
}
