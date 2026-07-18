{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.go-neb;

  settingsFormat = pkgs.formats.yaml { };
  configFile = settingsFormat.generate "config.yaml" cfg.config;
in
{
  options.services.go-neb = {
    config = lib.mkOption {
      inherit (settingsFormat) type;

      description = ''
        Your {file}`config.yaml` as a Nix attribute set.
        See [config.sample.yaml](https://github.com/matrix-org/go-neb/blob/master/config.sample.yaml)
        for possible options.
      '';
    };

    enable = lib.mkEnableOption "an extensible matrix bot written in Go";

    baseUrl = lib.mkOption {
      description = "Public-facing endpoint that can receive webhooks.";
      type = lib.types.str;
    };

    bindAddress = lib.mkOption {
      default = ":4050";
      description = "Port (and optionally address) to listen on.";
      type = lib.types.str;
    };

    secretFile = lib.mkOption {
      default = null;

      description = ''
        Environment variables from this file will be interpolated into the
        final config file using envsubst with this syntax: `$ENVIRONMENT`
        or `''${VARIABLE}`.
        The file should contain lines formatted as `SECRET_VAR=SECRET_VALUE`.
        This is useful to avoid putting secrets into the nix store.
      '';

      example = "/run/keys/go-neb.env";
      type = lib.types.nullOr lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.go-neb =
      let
        finalConfigFile = if cfg.secretFile == null then configFile else "/var/run/go-neb/config.yaml";
      in
      {
        after = [ "network.target" ];
        description = "Extensible matrix bot written in Go";

        environment = {
          BASE_URL = cfg.baseUrl;
          BIND_ADDRESS = cfg.bindAddress;
          CONFIG_FILE = finalConfigFile;
        };

        serviceConfig = {
          DynamicUser = true;
          ExecStart = "${pkgs.go-neb}/bin/go-neb";

          ExecStartPre = lib.optional (cfg.secretFile != null) (
            "+"
            + pkgs.writeShellScript "pre-start" ''
              umask 077
              export $(xargs < ${cfg.secretFile})
              ${pkgs.envsubst}/bin/envsubst -i "${configFile}" > ${finalConfigFile}
              chown go-neb ${finalConfigFile}
            ''
          );

          RuntimeDirectory = "go-neb";
          User = "go-neb";
        };

        wantedBy = [ "multi-user.target" ];
      };
  };

  meta.maintainers = with lib.maintainers; [
    hexa
    maralorn
  ];
}
