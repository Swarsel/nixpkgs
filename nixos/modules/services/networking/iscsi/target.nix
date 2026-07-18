{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.target;
in
{
  ###### interface
  options = {
    services.target = with types; {
      config = mkOption {
        default = { };

        description = ''
          Content of /etc/target/saveconfig.json
          This file is normally read and written by targetcli
        '';

        type = attrs;
      };

      enable = mkEnableOption "the kernel's LIO iscsi target";
    };
  };

  ###### implementation
  config = mkIf cfg.enable {
    boot.kernelModules = [
      "configfs"
      "target_core_mod"
      "iscsi_target_mod"
    ];

    environment.etc."target/saveconfig.json" = {
      mode = "0600";
      text = builtins.toJSON cfg.config;
    };

    environment.systemPackages = with pkgs; [ targetcli-fb ];

    systemd.services.iscsi-target = {
      enable = true;

      after = [
        "network.target"
        "local-fs.target"
      ];

      requires = [ "sys-kernel-config.mount" ];

      serviceConfig = {
        ExecStart = "${lib.getExe pkgs.python3Packages.rtslib-fb} restore";
        ExecStop = "${lib.getExe pkgs.python3Packages.rtslib-fb} clear";
        RemainAfterExit = "yes";
        Type = "oneshot";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d /etc/target 0700 root root - -"
    ];
  };
}
