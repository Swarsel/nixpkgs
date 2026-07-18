{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.ejabberd;

  ctlcfg = pkgs.writeText "ejabberdctl.cfg" ''
    ERL_EPMD_ADDRESS=127.0.0.1
    ${cfg.ctlConfig}
  '';

  ectl = ''${cfg.package}/bin/ejabberdctl ${
    lib.optionalString (cfg.configFile != null) "--config ${cfg.configFile}"
  } --ctl-config "${ctlcfg}" --spool "${cfg.spoolDir}" --logs "${cfg.logsDir}"'';

  dumps = lib.escapeShellArgs cfg.loadDumps;

in
{

  ###### interface

  options = {

    services.ejabberd = {

      enable = lib.mkOption {
        default = false;
        description = "Whether to enable ejabberd server";
        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "ejabberd" { };

      configFile = lib.mkOption {
        default = null;
        description = "Configuration file for ejabberd in YAML format";
        type = lib.types.nullOr lib.types.path;
      };

      ctlConfig = lib.mkOption {
        default = "";
        description = "Configuration of ejabberdctl";
        type = lib.types.lines;
      };

      group = lib.mkOption {
        default = "ejabberd";
        description = "Group under which ejabberd is ran";
        type = lib.types.str;
      };

      imagemagick = lib.mkOption {
        default = false;
        description = "Add ImageMagick to server's path; allows for image thumbnailing";
        type = lib.types.bool;
      };

      loadDumps = lib.mkOption {
        default = [ ];
        description = "Configuration dumps that should be loaded on the first startup";
        example = lib.literalExpression "[ ./myejabberd.dump ]";
        type = lib.types.listOf lib.types.path;
      };

      logsDir = lib.mkOption {
        default = "/var/log/ejabberd";
        description = "Location of the logfile directory of ejabberd";
        type = lib.types.path;
      };

      spoolDir = lib.mkOption {
        default = "/var/lib/ejabberd";
        description = "Location of the spooldir of ejabberd";
        type = lib.types.path;
      };

      user = lib.mkOption {
        default = "ejabberd";
        description = "User under which ejabberd is ran";
        type = lib.types.str;
      };
    };

  };

  ###### implementation

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    security.pam.services.ejabberd = { };
    services.epmd.enable = true;

    systemd.services.ejabberd = {
      after = [
        "network.target"
        "epmd.socket"
      ];

      description = "ejabberd server";

      path = [
        pkgs.findutils
        pkgs.coreutils
      ]
      ++ lib.optional cfg.imagemagick pkgs.imagemagick;

      postStart = ''
        while ! ${ectl} status >/dev/null 2>&1; do
          if ! kill -0 "$MAINPID"; then exit 1; fi
          sleep 0.1
        done

        if [ -e "${cfg.spoolDir}/.firstRun" ]; then
          rm "${cfg.spoolDir}/.firstRun"
          for src in ${dumps}; do
            find "$src" -type f | while read dump; do
              echo "Loading configuration dump at $dump"
              ${ectl} load "$dump"
            done
          done
        fi
      '';

      preStart = ''
        if [ -z "$(ls -A '${cfg.spoolDir}')" ]; then
          touch "${cfg.spoolDir}/.firstRun"
        fi

        if ! test -e ${cfg.spoolDir}/.erlang.cookie; then
          touch ${cfg.spoolDir}/.erlang.cookie
          chmod 600 ${cfg.spoolDir}/.erlang.cookie
          dd if=/dev/random bs=16 count=1 | base64 > ${cfg.spoolDir}/.erlang.cookie
        fi
      '';

      serviceConfig = {
        ExecReload = "${ectl} reload_config";
        ExecStart = "${ectl} foreground";
        ExecStop = "${ectl} stop";
        Group = cfg.group;
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "epmd.socket" ];
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.logsDir}' 0750 ${cfg.user} ${cfg.group} -"
      "d '${cfg.spoolDir}' 0700 ${cfg.user} ${cfg.group} -"
    ];

    users.groups = lib.optionalAttrs (cfg.group == "ejabberd") {
      ejabberd.gid = config.ids.gids.ejabberd;
    };

    users.users = lib.optionalAttrs (cfg.user == "ejabberd") {
      ejabberd = {
        createHome = true;
        group = cfg.group;
        home = cfg.spoolDir;
        uid = config.ids.uids.ejabberd;
      };
    };

  };

}
