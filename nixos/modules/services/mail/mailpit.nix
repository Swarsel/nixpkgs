{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.services.mailpit) instances;
  inherit (lib)
    cli
    concatStringsSep
    const
    filterAttrs
    getExe
    mapAttrs'
    mkIf
    mkOption
    nameValuePair
    types
    ;

  isNonNull = v: v != null;
  genCliFlags =
    settings: concatStringsSep " " (cli.toCommandLineGNU { } (filterAttrs (const isNonNull) settings));
in
{
  options.services.mailpit.instances = mkOption {
    default = { };

    description = ''
      Configure mailpit instances. The attribute-set values are
      CLI flags passed to the `mailpit` CLI.

      See [upstream docs](https://mailpit.axllent.org/docs/configuration/runtime-options/)
      for all available options.
    '';

    type = types.attrsOf (
      types.submodule {
        options = {
          database = mkOption {
            default = null;

            description = ''
              Specify the local database filename to store persistent data.
              If `null`, a temporary file will be created that will be removed when the application stops.
              It's recommended to specify a relative path. The database will be written into the service's
              state directory then.
            '';

            example = "mailpit.db";
            type = types.nullOr types.str;
          };

          listen = mkOption {
            default = "127.0.0.1:8025";

            description = ''
              HTTP bind interface and port for UI.
            '';

            type = types.str;
          };

          max = mkOption {
            default = 500;

            description = ''
              Maximum number of emails to keep. If the number is exceeded, old emails
              will be deleted.

              Set to `0` to never prune old emails.
            '';

            type = types.ints.unsigned;
          };

          smtp = mkOption {
            default = "127.0.0.1:1025";

            description = ''
              SMTP bind interface and port.
            '';

            type = types.str;
          };
        };

        freeformType = types.attrsOf (
          types.oneOf [
            types.str
            types.int
            types.bool
          ]
        );
      }
    );
  };

  config = mkIf (instances != { }) {
    systemd.services = mapAttrs' (
      name: cfg:
      nameValuePair "mailpit-${name}" {
        after = [ "network-online.target" ];

        serviceConfig = {
          DynamicUser = true;
          ExecStart = "${getExe pkgs.mailpit} ${genCliFlags cfg}";
          Restart = "on-failure";
          StateDirectory = "mailpit";
          WorkingDirectory = "%S/mailpit";
        };

        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
      }
    ) instances;
  };

  meta.maintainers = [
    lib.maintainers.leona
    lib.maintainers.osnyx
  ];
}
