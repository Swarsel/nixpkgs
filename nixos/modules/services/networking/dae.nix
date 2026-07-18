{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.dae;
  assets = cfg.assets;
  genAssetsDrv =
    paths:
    pkgs.symlinkJoin {
      inherit paths;
      name = "dae-assets";
    };
in
{
  options = {
    services.dae = with lib; {
      config = mkOption {
        default = null;

        description = ''
          WARNING: This option will expose store your config unencrypted world-readable in the nix store.
          Config text for dae.

          See <https://github.com/daeuniverse/dae/blob/main/example.dae>.
        '';

        type = with types; (nullOr str);
      };

      enable = mkEnableOption "dae, a Linux high-performance transparent proxy solution based on eBPF";
      package = mkPackageOption pkgs "dae" { };

      assets = mkOption {
        default = with pkgs; [
          v2ray-geoip
          v2ray-domain-list-community
        ];

        defaultText = literalExpression "with pkgs; [ v2ray-geoip v2ray-domain-list-community ]";

        description = ''
          Assets required to run dae.
        '';

        type = with types; (listOf path);
      };

      assetsPath = mkOption {
        default = "${genAssetsDrv assets}/share/v2ray";

        defaultText = literalExpression ''
          (symlinkJoin {
              name = "dae-assets";
              paths = assets;
          })/share/v2ray
        '';

        description = ''
          The path which contains geolocation database.
          This option will override `assets`.
        '';

        type = types.str;
      };

      configFile = mkOption {
        default = null;

        description = ''
          The path of dae config file, end with `.dae`.
        '';

        example = "/path/to/your/config.dae";
        type = with types; (nullOr path);
      };

      disableTxChecksumIpGeneric = mkEnableOption "" // {
        description = "See <https://github.com/daeuniverse/dae/issues/43>";
      };

      openFirewall = mkOption {
        default = {
          enable = true;
          port = 12345;
        };

        defaultText = literalExpression ''
          {
            enable = true;
            port = 12345;
          }
        '';

        description = ''
          Open the firewall port.
        '';

        type =
          with types;
          submodule {
            options = {
              enable = mkEnableOption "opening {option}`port` in the firewall";

              port = mkOption {
                description = ''
                  Port to be opened. Consist with field `tproxy_port` in config file.
                '';

                type = types.port;
              };
            };
          };
      };

    };
  };

  config =
    lib.mkIf cfg.enable

      {
        assertions = [
          {
            assertion = !((config.services.dae.config != null) && (config.services.dae.configFile != null));

            message = ''
              Option `config` and `configFile` could not be set
              at the same time.
            '';
          }

          {
            assertion = !((config.services.dae.config == null) && (config.services.dae.configFile == null));

            message = ''
              Either `config` or `configFile` should be set.
            '';
          }
        ];

        environment.systemPackages = [ cfg.package ];

        networking = lib.mkIf cfg.openFirewall.enable {
          firewall =
            let
              portToOpen = cfg.openFirewall.port;
            in
            {
              allowedTCPPorts = [ portToOpen ];
              allowedUDPPorts = [ portToOpen ];
            };
        };

        systemd.packages = [ cfg.package ];

        systemd.services.dae =
          let
            daeBin = lib.getExe cfg.package;

            configPath =
              if cfg.configFile != null then cfg.configFile else pkgs.writeText "config.dae" cfg.config;

            TxChecksumIpGenericWorkaround =
              with lib;
              (getExe pkgs.writeShellApplication {
                name = "disable-tx-checksum-ip-generic";

                text = with pkgs; ''
                  iface=$(${iproute2}/bin/ip route | ${lib.getExe gawk} '/default/ {print $5}')
                  ${lib.getExe ethtool} -K "$iface" tx-checksum-ip-generic off
                '';
              });
          in
          {
            serviceConfig = {
              Environment = "DAE_LOCATION_ASSET=${cfg.assetsPath}";

              ExecStart = [
                ""
                "${daeBin} run --disable-timestamp -c \${CREDENTIALS_DIRECTORY}/config.dae"
              ];

              ExecStartPre = [
                ""
                "${daeBin} validate -c \${CREDENTIALS_DIRECTORY}/config.dae"
              ]
              ++ (with lib; optional cfg.disableTxChecksumIpGeneric TxChecksumIpGenericWorkaround);

              LoadCredential = [ "config.dae:${configPath}" ];
            };

            wantedBy = [ "multi-user.target" ];
          };
      };

  meta.maintainers = with lib.maintainers; [
    pokon548
    oluceps
  ];
}
