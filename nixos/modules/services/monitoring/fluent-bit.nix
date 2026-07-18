{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.services.fluent-bit;

  yamlFormat = pkgs.formats.yaml { };
in
{
  options.services.fluent-bit = {
    enable = lib.mkEnableOption "Fluent Bit";
    package = lib.mkPackageOption pkgs "fluent-bit" { };

    configurationFile = lib.mkOption {
      default = yamlFormat.generate "fluent-bit.yaml" cfg.settings;
      defaultText = lib.literalExpression ''yamlFormat.generate "fluent-bit.yaml" cfg.settings'';

      description = ''
        Fluent Bit configuration. See
        <https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/yaml>
        for supported values.

        {option}`configurationFile` takes precedence over {option}`settings`.

        Note: Restricted evaluation blocks access to paths outside the Nix store.
        This means detecting content changes for mutable paths (i.e. not input or content-addressed) can't be done.
        As a result, `nixos-rebuild` won't reload/restart the systemd unit when mutable path contents change.
        `systemctl restart fluent-bit.service` must be used instead.
      '';

      example = "/etc/fluent-bit/fluent-bit.yaml";
      type = lib.types.path;
    };

    # See https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/yaml/service-section.
    graceLimit = lib.mkOption {
      default = null;

      description = ''
        The grace time limit. Sets the systemd unit's `TimeoutStopSec`.

        The `service.grace` option in the Fluent Bit configuration should be ≤ this option.
      '';

      example = 30;

      type = lib.types.nullOr (
        lib.types.oneOf [
          lib.types.ints.positive
          lib.types.str
        ]
      );
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        See {option}`configurationFile`.

        {option}`configurationFile` takes precedence over {option}`settings`.
      '';

      example = {
        pipeline = {
          inputs = [
            {
              name = "systemd";
              systemd_filter = "_SYSTEMD_UNIT=fluent-bit.service";
            }
          ];

          outputs = [
            {
              file = "fluent-bit.out";
              name = "file";
              path = "/var/log/fluent-bit";
            }
          ];
        };

        service = {
          grace = 30;
        };
      };

      type = yamlFormat.type;
    };
  };

  config = lib.mkIf cfg.enable {
    # See https://github.com/fluent/fluent-bit/blob/v3.2.6/init/systemd.in.
    systemd.services.fluent-bit = {
      after = [ "network.target" ];
      description = "Fluent Bit";
      requires = [ "network.target" ];

      serviceConfig = {
        DynamicUser = true;

        ExecStart = utils.escapeSystemdExecArgs [
          (lib.getExe cfg.package)
          "--config"
          cfg.configurationFile
        ];

        Restart = "always";
        # See https://nixos.org/manual/nixos/stable#sec-logging.
        SupplementaryGroups = "systemd-journal";
        TimeoutStopSec = lib.mkIf (cfg.graceLimit != null) cfg.graceLimit;
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
