{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.munge;

in

{

  ###### interface

  options = {

    services.munge = {
      enable = lib.mkEnableOption "munge service";

      password = lib.mkOption {
        default = "/etc/munge/munge.key";

        description = ''
          The path to a daemon's secret key.
        '';

        type = lib.types.path;
      };

    };

  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ pkgs.munge ];

    systemd.services.munged = {
      after = [
        "network-online.target"
        "time-sync.target"
      ];

      documentation = [
        "man:munged(8)"
        "man:mungekey(8)"
      ];

      path = [
        pkgs.munge
        pkgs.coreutils
      ];

      serviceConfig = {
        ExecStart = "${pkgs.munge}/bin/munged --foreground --key-file ${cfg.password}";
        ExecStartPre = "+${pkgs.coreutils}/bin/chmod 0400 ${cfg.password}";
        Group = "munge";
        Restart = "on-failure";
        RuntimeDirectory = "munge";
        StateDirectory = "munge";
        StateDirectoryMode = "0711";
        User = "munge";
      };

      wantedBy = [ "multi-user.target" ];

      wants = [
        "network-online.target"
        "time-sync.target"
      ];

    };

    users.groups.munge = { };

    users.users.munge = {
      description = "Munge daemon user";
      group = "munge";
      isSystemUser = true;
    };

  };

}
