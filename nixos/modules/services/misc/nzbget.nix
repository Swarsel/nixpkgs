{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.nzbget;
  stateDir = "/var/lib/nzbget";
  configFile = "${stateDir}/nzbget.conf";
  configOpts = lib.concatStringsSep " " (
    lib.mapAttrsToList (name: value: "-o ${name}=${lib.escapeShellArg (toStr value)}") cfg.settings
  );
  toStr =
    v:
    if v == true then
      "yes"
    else if v == false then
      "no"
    else if lib.isInt v then
      toString v
    else
      v;
in
{
  imports = [
    (lib.mkRemovedOptionModule [
      "services"
      "misc"
      "nzbget"
      "configFile"
    ] "The configuration of nzbget is now managed by users through the web interface.")
    (lib.mkRemovedOptionModule [
      "services"
      "misc"
      "nzbget"
      "dataDir"
    ] "The data directory for nzbget is now /var/lib/nzbget.")
    (lib.mkRemovedOptionModule [ "services" "misc" "nzbget" "openFirewall" ]
      "The port used by nzbget is managed through the web interface so you should adjust your firewall rules accordingly."
    )
  ];

  # interface

  options = {
    services.nzbget = {
      enable = lib.mkEnableOption "NZBGet, for downloading files from news servers";
      package = lib.mkPackageOption pkgs "nzbget" { };

      group = lib.mkOption {
        default = "nzbget";
        description = "Group under which NZBGet runs";
        type = lib.types.str;
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          NZBGet configuration, passed via command line using switch -o. Refer to
          <https://github.com/nzbgetcom/nzbget/blob/develop/nzbget.conf>
          for details on supported values.
        '';

        example = {
          MainDir = "/data";
        };

        type =
          with lib.types;
          attrsOf (oneOf [
            bool
            int
            str
          ]);
      };

      user = lib.mkOption {
        default = "nzbget";
        description = "User account under which NZBGet runs";
        type = lib.types.str;
      };
    };
  };

  # implementation

  config = lib.mkIf cfg.enable {
    services.nzbget.settings = {
      # required paths
      ConfigTemplate = "${cfg.package}/share/nzbget/nzbget.conf";
      DetailTarget = "screen";
      ErrorTarget = "screen";
      InfoTarget = "screen";
      # allows nzbget to run as a "simple" service
      OutputMode = "loggable";
      # nixos handles package updates
      UpdateCheck = "none";
      WarningTarget = "screen";
      WebDir = "${cfg.package}/share/nzbget/webui";
      # use journald for logging
      WriteLog = "none";
    };

    systemd.services.nzbget = {
      after = [ "network.target" ];
      description = "NZBGet Daemon";

      path = with pkgs; [
        unrar
        p7zip
      ];

      preStart = ''
        if [ ! -f ${configFile} ]; then
          ${pkgs.coreutils}/bin/install -m 0700 ${cfg.package}/share/nzbget/nzbget.conf ${configFile}
        fi
      '';

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/nzbget --server --configfile ${stateDir}/nzbget.conf ${configOpts}";
        ExecStop = "${cfg.package}/bin/nzbget --quit";
        Group = cfg.group;
        Restart = "on-failure";
        StateDirectory = "nzbget";
        StateDirectoryMode = "0750";
        UMask = "0002";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups = lib.mkIf (cfg.group == "nzbget") {
      nzbget = {
        gid = config.ids.gids.nzbget;
      };
    };

    users.users = lib.mkIf (cfg.user == "nzbget") {
      nzbget = {
        group = cfg.group;
        home = stateDir;
        uid = config.ids.uids.nzbget;
      };
    };
  };
}
