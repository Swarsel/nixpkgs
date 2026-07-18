{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  opt = options.services.rkvm;
  cfg = config.services.rkvm;
  toml = pkgs.formats.toml { };
in
{
  options.services.rkvm = {
    enable = lib.mkOption {
      default = cfg.server.enable || cfg.client.enable;
      defaultText = lib.literalExpression "config.${opt.server.enable} || config.${opt.client.enable}";

      description = ''
        Whether to enable rkvm, a Virtual KVM switch for Linux machines.
      '';

      type = lib.types.bool;
    };

    package = lib.mkPackageOption pkgs "rkvm" { };

    client = {
      enable = lib.mkEnableOption "the rkvm client daemon (input receiver)";

      settings = lib.mkOption {
        default = { };
        description = "Structured client daemon configuration";

        type = lib.types.submodule {
          options = {
            certificate = lib.mkOption {
              default = "/etc/rkvm/certificate.pem";

              description = ''
                TLS ceritficate path.

                ::: {.note}
                This should be generated with {command}`rkvm-certificate-gen`.
                :::
              '';

              type = lib.types.path;
            };

            password = lib.mkOption {
              description = ''
                Shared secret token to authenticate the client.
                Make sure this matches your server's config.
              '';

              type = lib.types.str;
            };

            server = lib.mkOption {
              description = ''
                An RKVM server's internet socket address, either IPv4 or IPv6.
              '';

              example = "192.168.0.123:5258";
              type = lib.types.str;
            };
          };

          freeformType = toml.type;
        };
      };
    };

    server = {
      enable = lib.mkEnableOption "the rkvm server daemon (input transmitter)";

      settings = lib.mkOption {
        default = { };
        description = "Structured server daemon configuration";

        type = lib.types.submodule {
          options = {
            certificate = lib.mkOption {
              default = "/etc/rkvm/certificate.pem";

              description = ''
                TLS certificate path.

                ::: {.note}
                This should be generated with {command}`rkvm-certificate-gen`.
                :::
              '';

              type = lib.types.path;
            };

            key = lib.mkOption {
              default = "/etc/rkvm/key.pem";

              description = ''
                TLS key path.

                ::: {.note}
                This should be generated with {command}`rkvm-certificate-gen`.
                :::
              '';

              type = lib.types.path;
            };

            listen = lib.mkOption {
              default = "0.0.0.0:5258";

              description = ''
                An internet socket address to listen on, either IPv4 or IPv6.
              '';

              type = lib.types.str;
            };

            password = lib.mkOption {
              description = ''
                Shared secret token to authenticate the client.
                Make sure this matches your client's config.
              '';

              type = lib.types.str;
            };

            switch-keys = lib.mkOption {
              default = [
                "left-alt"
                "left-ctrl"
              ];

              description = ''
                A key list specifying a host switch combination.

                _A list of key names is available in <https://github.com/htrefil/rkvm/blob/master/switch-keys.md>._
              '';

              type = lib.types.listOf lib.types.str;
            };
          };

          freeformType = toml.type;
        };
      };
    };

  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services =
      let
        mkBase = component: {
          after =
            {
              client = [ "network-online.target" ];
              server = [ "network.target" ];
            }
            .${component};

          description = "RKVM ${component}";

          serviceConfig = {
            ExecStart = "${cfg.package}/bin/rkvm-${component} ${
              toml.generate "rkvm-${component}.toml" cfg.${component}.settings
            }";

            Restart = "always";
            RestartSec = 5;
            Type = "simple";
          };

          wantedBy = [ "multi-user.target" ];

          wants =
            {
              client = [ "network-online.target" ];
              server = [ ];
            }
            .${component};
        };
      in
      {
        rkvm-client = lib.mkIf cfg.client.enable (mkBase "client");
        rkvm-server = lib.mkIf cfg.server.enable (mkBase "server");
      };
  };

  meta.maintainers = [ ];

}
