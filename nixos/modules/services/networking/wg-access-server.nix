{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkOption
    types
    ;

  cfg = config.services.wg-access-server;

  settingsFormat = pkgs.formats.yaml { };
  configFile = settingsFormat.generate "config.yaml" cfg.settings;
in
{

  options.services.wg-access-server = {
    enable = mkEnableOption "wg-access-server";
    package = mkPackageOption pkgs "wg-access-server" { };

    secretsFile = mkOption {
      description = ''
        yaml file containing all secrets. this needs to be in the same structure as the configuration.

        This must to contain the admin password and wireguard private key.
        As well as the secrets for your auth backend.

        Example:
        ```yaml
        adminPassword: <admin password>
        wireguard:
          privateKey: <wireguard private key>
        auth:
          oidc:
            clientSecret: <client secret>
        ```
      '';

      type = types.path;
    };

    settings = mkOption {
      description = "See <https://www.freie-netze.org/wg-access-server/2-configuration/> for possible options";

      type = lib.types.submodule {
        options = {
          dns.enabled = mkOption {
            default = true;

            description = ''
              Enable/disable the embedded DNS proxy server.
              This is enabled by default and allows VPN clients to avoid DNS leaks by sending all DNS requests to wg-access-server itself.
            '';

            type = types.bool;
          };

          storage = mkOption {
            default = "sqlite3://db.sqlite";
            description = "A storage backend connection string. See [storage docs](https://www.freie-netze.org/wg-access-server/3-storage/)";
            type = types.str;
          };
        };

        freeformType = settingsFormat.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions =
      map
        (attrPath: {
          assertion = !lib.hasAttrByPath attrPath config.services.wg-access-server.settings;

          message = ''
            {option}`services.wg-access-server.settings.${lib.concatStringsSep "." attrPath}` must definded
            in {option}`services.wg-access-server.secretsFile`.
          '';
        })
        [
          [ "adminPassword" ]
          [
            "wireguard"
            "privateKey"
          ]
          [
            "auth"
            "sessionStore"
          ]
          [
            "auth"
            "oidc"
            "clientSecret"
          ]
          [
            "auth"
            "gitlab"
            "clientSecret"
          ]
        ];

    boot.kernel.sysctl = {
      "net.ipv4.conf.all.forwarding" = "1";
      "net.ipv6.conf.all.forwarding" = "1";
    };

    systemd.services.wg-access-server = {
      after = [ "network-online.target" ];
      description = "WG access server";

      path = with pkgs; [
        iptables
        # needed by startup script
        yq-go
      ];

      requires = [ "network-online.target" ];

      script = ''
        # merge secrets into main config
        yq eval-all "select(fileIndex == 0) * select(fileIndex == 1)" ${configFile} $CREDENTIALS_DIRECTORY/SECRETS_FILE \
          > "$STATE_DIRECTORY/config.yml"

        ${lib.getExe cfg.package} serve --config "$STATE_DIRECTORY/config.yml"
      '';

      serviceConfig =
        let
          capabilities = [
            "CAP_NET_ADMIN"
          ]
          ++ lib.optional cfg.settings.dns.enabled "CAP_NET_BIND_SERVICE";
        in
        {
          AmbientCapabilities = capabilities;
          CapabilityBoundingSet = capabilities;
          # Hardening
          DynamicUser = true;

          LoadCredential = [
            "SECRETS_FILE:${cfg.secretsFile}"
          ];

          StateDirectory = "wg-access-server";
          WorkingDirectory = "/var/lib/wg-access-server";
        };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
