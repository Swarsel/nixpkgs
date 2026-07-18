{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.cachefilesd;

  cfgFile = pkgs.writeText "cachefilesd.conf" ''
    dir ${cfg.cacheDir}
    ${cfg.extraConfig}
  '';

in

{
  options = {
    services.cachefilesd = {

      enable = lib.mkOption {
        default = false;
        description = "Whether to enable cachefilesd network filesystems caching daemon.";
        type = lib.types.bool;
      };

      cacheDir = lib.mkOption {
        default = "/var/cache/fscache";
        description = "Directory to contain filesystem cache.";
        type = lib.types.str;
      };

      extraConfig = lib.mkOption {
        default = "";
        description = "Additional configuration file entries. See {manpage}`cachefilesd.conf(5)` for more information.";
        example = "brun 10%";
        type = lib.types.lines;
      };

    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    boot.kernelModules = [ "cachefiles" ];

    systemd.services.cachefilesd = {
      description = "Local network file caching management daemon";

      serviceConfig = {
        ExecStart = "${pkgs.cachefilesd}/bin/cachefilesd -n -f ${cfgFile}";
        PrivateTmp = true;
        Restart = "on-failure";
        Type = "exec";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.settings."10-cachefilesd".${cfg.cacheDir}.d = {
      group = "root";
      mode = "0700";
      user = "root";
    };
  };
}
