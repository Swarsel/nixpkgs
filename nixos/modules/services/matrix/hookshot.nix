{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.matrix-hookshot;
  settingsFormat = pkgs.formats.yaml { };
  configFile = settingsFormat.generate "matrix-hookshot-config.yml" cfg.settings;
in
{
  options = {
    services.matrix-hookshot = {
      enable = lib.mkEnableOption "matrix-hookshot, a bridge between Matrix and project management services";
      package = lib.mkPackageOption pkgs "matrix-hookshot" { };

      registrationFile = lib.mkOption {
        description = ''
          Appservice registration file.
          As it contains secret tokens, you may not want to add this to the publicly readable Nix store.
        '';

        example = lib.literalExpression ''
          pkgs.writeText "matrix-hookshot-registration" \'\'
            id: matrix-hookshot
            as_token: aaaaaaaaaa
            hs_token: aaaaaaaaaa
            namespaces:
              rooms: []
              users:
                - regex: "@_webhooks_.*:foobar"
                  exclusive: true

            sender_localpart: hookshot
            url: "http://localhost:9993"
            rate_limited: false
            \'\'
        '';

        type = lib.types.path;
      };

      serviceDependencies = lib.mkOption {
        default = lib.optional config.services.matrix-synapse.enable config.services.matrix-synapse.serviceUnit;

        defaultText = lib.literalExpression ''
          lib.optional config.services.matrix-synapse.enable config.services.matrix-synapse.serviceUnit
        '';

        description = ''
          List of Systemd services to require and wait for when starting the application service,
          such as the Matrix homeserver if it's running on the same host.
        '';

        type = with lib.types; listOf str;
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          {file}`config.yml` configuration as a Nix attribute set.

          For details please see the [documentation](https://matrix-org.github.io/matrix-hookshot/latest/setup/sample-configuration.html).
        '';

        example = {
          bridge = {
            bindAddress = "127.0.0.1";
            domain = "example.com";
            mediaUrl = "https://example.com";
            port = 9993;
            url = "http://localhost:8008";
          };

          listeners = [
            {
              bindAddress = "0.0.0.0";
              port = 9000;
              resources = [ "webhooks" ];
            }
            {
              bindAddress = "localhost";
              port = 9001;

              resources = [
                "metrics"
                "provisioning"
              ];
            }
          ];
        };

        type = lib.types.submodule {
          options = {
            passFile = lib.mkOption {
              default = "/var/lib/matrix-hookshot/passkey.pem";

              description = ''
                A passkey used to encrypt tokens stored inside the bridge.
                File will be generated if not found.
              '';

              type = lib.types.path;
            };
          };

          freeformType = settingsFormat.type;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.matrix-hookshot = {
      after = [ "network-online.target" ] ++ cfg.serviceDependencies;
      description = "a bridge between Matrix and multiple project management services";

      preStart = ''
        if [ ! -f '${cfg.settings.passFile}' ]; then
          mkdir -p $(dirname '${cfg.settings.passFile}')
          ${pkgs.openssl}/bin/openssl genpkey -out '${cfg.settings.passFile}' -outform PEM -algorithm RSA -pkeyopt rsa_keygen_bits:4096
        fi
      '';

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/matrix-hookshot ${configFile} ${cfg.registrationFile}";
        Restart = "always";
        Type = "simple";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ] ++ cfg.serviceDependencies;
    };
  };

  meta.maintainers = with lib.maintainers; [ flandweber ];
}
