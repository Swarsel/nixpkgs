{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.corerad;
  settingsFormat = pkgs.formats.toml { };

in
{
  options.services.corerad = {
    enable = lib.mkEnableOption "CoreRAD IPv6 NDP RA daemon";
    package = lib.mkPackageOption pkgs "corerad" { };

    configFile = lib.mkOption {
      description = "Path to CoreRAD TOML configuration file.";
      example = lib.literalExpression ''"''${pkgs.corerad}/etc/corerad/corerad.toml"'';
      type = lib.types.path;
    };

    settings = lib.mkOption {
      description = ''
        Configuration for CoreRAD, see <https://github.com/mdlayher/corerad/blob/main/internal/config/reference.toml>
        for supported values. Ignored if configFile is set.
      '';

      example = lib.literalExpression ''
        {
          interfaces = [
            # eth0 is an upstream interface monitoring for IPv6 router advertisements.
            {
              name = "eth0";
              monitor = true;
            }
            # eth1 is a downstream interface advertising IPv6 prefixes for SLAAC.
            {
              name = "eth1";
              advertise = true;
              prefix = [{ prefix = "::/64"; }];
            }
          ];
          # Optionally enable Prometheus metrics.
          debug = {
            address = "localhost:9430";
            prometheus = true;
          };
        }
      '';

      type = settingsFormat.type;
    };
  };

  config = lib.mkIf cfg.enable {
    # Prefer the config file over settings if both are set.
    services.corerad.configFile = lib.mkDefault (settingsFormat.generate "corerad.toml" cfg.settings);

    systemd.services.corerad = {
      after = [ "network.target" ];
      description = "CoreRAD IPv6 NDP RA daemon";

      serviceConfig = {
        AmbientCapabilities = "CAP_NET_ADMIN CAP_NET_RAW";
        CapabilityBoundingSet = "CAP_NET_ADMIN CAP_NET_RAW";
        DynamicUser = true;
        ExecStart = "${lib.getBin cfg.package}/bin/corerad -c=${cfg.configFile}";
        LimitNOFILE = 1048576;
        LimitNPROC = 512;
        NoNewPrivileges = true;
        NotifyAccess = "main";
        Restart = "on-failure";
        RestartKillSignal = "SIGHUP";
        Type = "notify";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ mdlayher ];
}
