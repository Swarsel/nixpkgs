{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.networking.networkmanager;
  toml = pkgs.formats.toml { };

  enabled = (lib.length cfg.ensureProfiles.secrets.entries) > 0;

  nmFileSecretAgentConfig = {
    entry = map (
      i:
      {
        file = i.file;
        key = i.key;
      }
      // lib.optionalAttrs (i.matchId != null) { match_id = i.matchId; }
      // lib.optionalAttrs (i.matchUuid != null) { match_uuid = i.matchUuid; }
      // lib.optionalAttrs (i.matchType != null) { match_type = i.matchType; }
      // lib.optionalAttrs (i.matchIface != null) { match_iface = i.matchIface; }
      // lib.optionalAttrs (i.matchSetting != null) {
        match_setting = i.matchSetting;
      }
      // lib.optionalAttrs (i.trim != null) { trim = i.trim; }
    ) cfg.ensureProfiles.secrets.entries;
  };
  nmFileSecretAgentConfigFile = toml.generate "config.toml" nmFileSecretAgentConfig;
in
{
  ####### interface
  options = {
    networking.networkmanager.ensureProfiles.secrets = {
      package = lib.mkPackageOption pkgs "nm-file-secret-agent" { };

      entries = lib.mkOption {
        default = [ ];

        description = ''
          A list of secrets to provide to NetworkManager by reading their values from configured files.

          Note that NetworkManager should be configured to read secrets from a secret agent.
          This can be done for example through the `networking.networkmanager.ensureProfiles.profiles` options.
        '';

        example = [
          {
            file = "/root/wireguard_key";
            key = "private-key";
            matchId = "My WireGuard VPN";
            matchSetting = "wireguard";
            matchType = "wireguard";
          }
        ];

        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              file = lib.mkOption {
                description = "file from which the secret value is read";
                type = lib.types.str;
              };

              key = lib.mkOption {
                description = "key in the setting section for which this entry provides a value";
                type = lib.types.str;
              };

              matchId = lib.mkOption {
                default = null;

                description = ''
                  connection id used by NetworkManager. Often displayed as name in GUIs.

                  NetworkManager describes this as a human readable unique identifier for the connection, like "Work Wi-Fi" or "T-Mobile 3G".
                '';

                example = "wifi1";
                type = lib.types.nullOr lib.types.str;
              };

              matchIface = lib.mkOption {
                default = null;
                description = "interface name of the NetworkManager connection";
                type = lib.types.nullOr lib.types.str;
              };

              matchSetting = lib.mkOption {
                default = null;
                description = "name of the setting section for which secrets are requested";
                type = lib.types.nullOr lib.types.str;
              };

              matchType = lib.mkOption {
                default = null;

                description = ''
                  NetworkManager connection type

                  The NetworkManager configuration settings reference roughly corresponds to connection types.
                  More might be available on your system depending on the installed plugins.

                  <https://networkmanager.dev/docs/api/latest/ch01.html>
                '';

                example = "wireguard";
                type = lib.types.nullOr lib.types.str;
              };

              matchUuid = lib.mkOption {
                default = null;

                description = ''
                  UUID of the connection profile

                  UUIDs are assigned once on connection creation and should never change as long as the connection still applies to the same network.
                '';

                example = "669ea4c9-4cb3-4901-ab52-f9606590976e";
                type = lib.types.nullOr lib.types.str;
              };

              trim = lib.mkOption {
                default = true;
                description = "whether leading and trailing whitespace should be stripped from the files content before being passed to NetworkManager";
                type = lib.types.nullOr lib.types.bool;
              };
            };
          }
        );
      };
    };
  };

  ####### implementation
  config = lib.mkIf enabled {
    # start nm-file-secret-agent if required
    systemd.services."nm-file-secret-agent" = {
      after = [ "NetworkManager.service" ];
      description = "NetworkManager secret agent that responds with the content of preconfigured files";
      documentation = [ "https://github.com/lilioid/nm-file-secret-agent/" ];
      requires = [ "NetworkManager.service" ];
      restartTriggers = [ nmFileSecretAgentConfigFile ];
      script = "${lib.getExe cfg.ensureProfiles.secrets.package} --conf ${nmFileSecretAgentConfigFile}";
      wantedBy = [ "multi-user.target" ];
    };
  };

  meta = {
    maintainers = [ lib.maintainers.lilioid ];
  };
}
