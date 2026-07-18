{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.taler;
  settingsFormat = pkgs.formats.ini { };
in

{
  # TODO turn this into a generic taler-like service thingy?
  options.services.taler = {
    enable = lib.mkEnableOption "the GNU Taler system" // lib.mkOption { internal = true; };

    includes = lib.mkOption {
      default = [ ];

      description = ''
        Files to include into the config file using Taler's `@inline@` directive.

        This allows including arbitrary INI files, including imperatively managed ones.
      '';

      type = lib.types.listOf lib.types.path;
    };

    runtimeDir = lib.mkOption {
      default = "/run/taler-system-runtime/";

      description = ''
        Runtime directory shared between the taler services.

        Crypto helpers put their sockets here for instance and the httpd
        connects to them.
      '';

      type = lib.types.str;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Global configuration options for the taler config file.

        For a list of all possible options, please see the man page [`taler.conf(5)`](https://docs.taler.net/manpages/taler.conf.5.html)
      '';

      type = lib.types.submodule {
        options = {
          taler = {
            CURRENCY = lib.mkOption {
              description = ''
                The currency which taler services will operate with. This cannot be changed later.
              '';

              type = lib.types.nonEmptyStr;
            };

            CURRENCY_ROUND_UNIT = lib.mkOption {
              default = "${cfg.settings.taler.CURRENCY}:0.01";

              defaultText = lib.literalExpression ''
                "''${config.services.taler.settings.taler.CURRENCY}:0.01"
              '';

              description = ''
                Smallest amount in this currency that can be transferred using the underlying RTGS.

                You should probably not touch this.
              '';

              type = lib.types.str;
            };
          };
        };

        freeformType = settingsFormat.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."taler/taler.conf".source =
      let
        includes = pkgs.writers.writeText "includes.conf" (
          lib.concatStringsSep "\n" (map (include: "@inline@ ${include}") cfg.includes)
        );
        generatedConfig = settingsFormat.generate "generated-taler.conf" cfg.settings;
      in
      pkgs.runCommand "taler.conf" { } ''
        cat ${includes} > $out
        echo >> $out
        echo >> $out
        cat ${generatedConfig} >> $out
      '';

    services.taler.settings.PATHS = {
      TALER_CACHE_HOME = "\${CACHE_DIRECTORY}/";
      TALER_DATA_HOME = "\${STATE_DIRECTORY}/";
      TALER_RUNTIME_DIR = cfg.runtimeDir;
    };

  };
}
