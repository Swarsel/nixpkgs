{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  globalCfg = config.services.scion;
  cfg = config.services.scion.scion-dispatcher;
  toml = pkgs.formats.toml { };
  defaultConfig = {
    dispatcher = {
      id = "dispatcher";
      local_udp_forwarding = true;
    };

    log.console = {
      level = "info";
    };
  };
  configFile = toml.generate "scion-dispatcher.toml" (recursiveUpdate defaultConfig cfg.settings);
in
{
  options.services.scion.scion-dispatcher = {
    enable = mkEnableOption "the scion-dispatcher service";

    settings = mkOption {
      default = { };

      description = ''
        scion-dispatcher configuration. Refer to
        <https://docs.scion.org/en/latest/manuals/common.html>
        for details on supported values.
      '';

      example = literalExpression ''
        {
          dispatcher = {
            id = "dispatcher";
            socket_file_mode = "0770";
            application_socket = "/dev/shm/dispatcher/default.sock";
          };
          log.console = {
            level = "info";
          };
        }
      '';

      type = toml.type;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.scion-dispatcher = {
      after = [ "network-online.target" ];
      description = "SCION Dispatcher";

      serviceConfig = {
        ${if globalCfg.stateless then "RuntimeDirectory" else "StateDirectory"} = "scion-dispatcher";
        BindPaths = [ "/dev/shm:/run/shm" ];
        DynamicUser = true;
        ExecStart = "${globalCfg.package}/bin/scion-dispatcher --config ${configFile}";
        ExecStartPre = "${pkgs.coreutils}/bin/rm -rf /run/shm/dispatcher";
        Group = "scion";
        Restart = "on-failure";
        Type = "simple";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

    # scion programs hardcode path to dispatcher in /run/shm, and is not
    # configurable at runtime upstream plans to obsolete the dispatcher in
    # favor of an SCMP daemon, at which point this can be removed.
    systemd.services.scion-dispatcher-prepare = {
      before = [ config.systemd.services.scion-dispatcher.name ];

      script = ''
        ln -sf /dev/shm /run/shm
      '';

      serviceConfig = {
        Type = "oneshot";
      };

      wantedBy = [ config.systemd.services.scion-dispatcher.name ];
    };

    # Needed for group ownership of the dispatcher socket
    users.groups.scion = { };
  };
}
