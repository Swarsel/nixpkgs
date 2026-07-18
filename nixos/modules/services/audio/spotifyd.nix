{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.spotifyd;
  toml = pkgs.formats.toml { };
  warnConfig =
    if cfg.config != "" then
      lib.trace "Using the stringly typed .config attribute is discouraged. Use the TOML typed .settings attribute instead."
    else
      lib.id;
  spotifydConf =
    if cfg.settings != { } then
      toml.generate "spotify.conf" cfg.settings
    else
      warnConfig (pkgs.writeText "spotifyd.conf" cfg.config);
in
{
  options = {
    services.spotifyd = {
      config = lib.mkOption {
        default = "";

        description = ''
          (Deprecated) Configuration for Spotifyd. For syntax and directives, see
          <https://docs.spotifyd.rs/configuration/index.html#config-file>.
        '';

        type = lib.types.lines;
      };

      enable = lib.mkEnableOption "spotifyd, a Spotify playing daemon";
      package = lib.mkPackageOption pkgs "spotifyd" { };

      settings = lib.mkOption {
        default = { };

        description = ''
          Configuration for Spotifyd. For syntax and directives, see
          <https://docs.spotifyd.rs/configuration/index.html#config-file>.
        '';

        example = {
          global.bitrate = 320;
        };

        type = toml.type;
      };

    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.config == "" || cfg.settings == { };
        message = "At most one of the .config attribute and the .settings attribute may be set";
      }
    ];

    systemd.services.spotifyd = {
      after = [
        "network-online.target"
        "sound.target"
      ];

      description = "spotifyd, a Spotify playing daemon";
      environment.SHELL = "/bin/sh";

      serviceConfig = {
        CacheDirectory = "spotifyd";
        DynamicUser = true;
        ExecStart = "${cfg.package}/bin/spotifyd --no-daemon --cache-path /var/cache/spotifyd --config-path ${spotifydConf}";
        Restart = "always";
        RestartSec = 12;
        SupplementaryGroups = [ "audio" ];
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta.maintainers = [ lib.maintainers.anderslundstedt ];
}
