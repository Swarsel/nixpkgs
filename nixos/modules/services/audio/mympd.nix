{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.mympd;
in
{
  options = {

    services.mympd = {

      enable = lib.mkEnableOption "MyMPD server";
      package = lib.mkPackageOption pkgs "mympd" { };

      extraGroups = lib.mkOption {
        default = [ ];

        description = ''
          Additional groups for the systemd service.
        '';

        example = [ "music" ];
        type = lib.types.listOf lib.types.str;
      };

      openFirewall = lib.mkOption {
        default = false;

        description = ''
          Open ports needed for the functionality of the program.
        '';

        type = lib.types.bool;
      };

      settings = lib.mkOption {
        description = ''
          Manages the configuration files declaratively. For all the configuration
          options, see <https://jcorporation.github.io/myMPD/020-configuration/configuration-files>.

          Each key represents the "File" column from the upstream configuration table, and the
          value is the content of that file.
        '';

        type = lib.types.submodule {
          options = {
            http_port = lib.mkOption {
              description = ''
                The HTTP port where mympd's web interface will be available.

                The HTTPS/SSL port can be configured via {option}`config`.
              '';

              example = "8080";
              type = lib.types.port;
            };

            ssl = lib.mkOption {
              default = false;

              description = ''
                Whether to enable listening on the SSL port.

                Refer to <https://jcorporation.github.io/myMPD/020-configuration/configuration-files#ssl-options>
                for more information.
              '';

              type = lib.types.bool;
            };
          };

          freeformType =
            with lib.types;
            attrsOf (
              nullOr (oneOf [
                str
                bool
                int
              ])
            );
        };
      };
    };

  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkMerge [
      (lib.mkIf cfg.openFirewall {
        allowedTCPPorts = [ cfg.settings.http_port ];
      })
      (lib.mkIf (cfg.openFirewall && cfg.settings.ssl && cfg.settings.ssl_port != null) {
        allowedTCPPorts = [ cfg.settings.ssl_port ];
      })
    ];

    systemd.services.mympd = {
      # upstream service config: https://github.com/jcorporation/myMPD/blob/master/contrib/initscripts/mympd.service.in
      after = [ "mpd.service" ];

      preStart = with lib; ''
        config_dir="/var/lib/mympd/config"
        mkdir -p "$config_dir"

        ${pipe cfg.settings [
          (mapAttrsToList (
            name: value: ''
              echo -n "${if isBool value then boolToString value else toString value}" > "$config_dir/${name}"
            ''
          ))
          (concatStringsSep "\n")
        ]}
      '';

      serviceConfig = {
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        CacheDirectory = "mympd";
        CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
        DynamicUser = true;
        ExecStart = lib.getExe cfg.package;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        RestrictAddressFamilies = "AF_INET AF_INET6 AF_NETLINK AF_UNIX";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        StateDirectory = "mympd";
        SupplementaryGroups = cfg.extraGroups;
        SystemCallArchitectures = "native";
        SystemCallFilter = "@system-service";
      };

      unitConfig = {
        Description = "myMPD server daemon";
        Documentation = "man:mympd(1)";
      };

      wantedBy = [ "multi-user.target" ];
    };

  };

  meta.maintainers = [ lib.maintainers.eliandoran ];

}
