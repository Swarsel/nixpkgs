{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.yandex-disk;

  dir = "/var/lib/yandex-disk";

  u = if cfg.user != null then cfg.user else "yandexdisk";

in

{

  ###### interface

  options = {

    services.yandex-disk = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable Yandex-disk client. See <https://disk.yandex.ru/>
        '';

        type = lib.types.bool;
      };

      directory = lib.mkOption {
        default = "/home/Yandex.Disk";
        description = "The directory to use for Yandex.Disk storage";
        type = lib.types.path;
      };

      excludes = lib.mkOption {
        default = "";

        description = ''
          Comma-separated list of directories which are excluded from synchronization.
        '';

        example = "data,backup";
        type = lib.types.commas;
      };

      password = lib.mkOption {
        default = "";

        description = ''
          Your yandex.com password. Warning: it will be world-readable in /nix/store.
        '';

        type = lib.types.str;
      };

      user = lib.mkOption {
        default = null;

        description = ''
          The user the yandex-disk daemon should run as.
        '';

        type = lib.types.nullOr lib.types.str;
      };

      username = lib.mkOption {
        default = "";

        description = ''
          Your yandex.com login name.
        '';

        type = lib.types.str;
      };

    };

  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    systemd.services.yandex-disk = {
      after = [ "network.target" ];
      description = "Yandex-disk server";

      script = ''
        mkdir -p -m 700 ${dir}
        chown ${u} ${dir}

        if ! test -d "${cfg.directory}" ; then
          (mkdir -p -m 755 ${cfg.directory} && chown ${u} ${cfg.directory}) ||
            exit 1
        fi

        ${pkgs.su}/bin/su -s ${pkgs.runtimeShell} ${u} \
          -c '${pkgs.yandex-disk}/bin/yandex-disk token -p ${cfg.password} ${cfg.username} ${dir}/token'

        ${pkgs.su}/bin/su -s ${pkgs.runtimeShell} ${u} \
          -c '${pkgs.yandex-disk}/bin/yandex-disk start --no-daemon -a ${dir}/token -d ${cfg.directory} --exclude-dirs=${cfg.excludes}'
      '';

      # FIXME: have to specify ${directory} here as well
      unitConfig.RequiresMountsFor = dir;
      wantedBy = [ "multi-user.target" ];

    };

    users.users = lib.mkIf (cfg.user == null) [
      {
        group = "nogroup";
        home = dir;
        name = u;
        uid = config.ids.uids.yandexdisk;
      }
    ];
  };

}
