{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.sonic-server;

  settingsFormat = pkgs.formats.toml { };
  configFile = settingsFormat.generate "sonic-server-config.toml" cfg.settings;

in
{
  options = {
    services.sonic-server = {
      enable = lib.mkEnableOption "Sonic Search Index";
      package = lib.mkPackageOption pkgs "sonic-server" { };

      settings = lib.mkOption {
        default = {
          store.fst.path = "/var/lib/sonic/fst";
          store.kv.path = "/var/lib/sonic/kv";
        };

        description = ''
          Sonic Server configuration options.

          Refer to
          <https://github.com/valeriansaliou/sonic/blob/master/CONFIGURATION.md>
          for a full list of available options.
        '';

        example = {
          channel.inet = "[::1]:1491";
          server.log_level = "debug";
        };

        type = lib.types.submodule { freeformType = settingsFormat.type; };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.sonic-server.settings = lib.mapAttrs (name: lib.mkDefault) {
      channel.search = { };
      server = { };

      store = {
        fst = {
          graph = { };
          path = "/var/lib/sonic/fst";
          pool = { };
        };

        kv = {
          database = { };
          path = "/var/lib/sonic/kv";
          pool = { };
        };
      };
    };

    systemd.services.sonic-server = {
      after = [ "network.target" ];
      description = "Sonic Search Index";

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${lib.getExe cfg.package} -c ${configFile}";
        Group = "sonic";
        LimitNOFILE = "infinity";
        Restart = "on-failure";
        StateDirectory = "sonic";
        StateDirectoryMode = "750";
        Type = "simple";
        User = "sonic";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = [ lib.maintainers.anthonyroussel ];
}
