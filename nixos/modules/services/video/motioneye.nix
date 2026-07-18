{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.motioneye;
in
{
  options.services.motioneye = {
    enable = lib.mkEnableOption "motionEye";

    group = lib.mkOption {
      default = "motioneye";
      description = "Group to run motionEye under.";
      type = lib.types.str;
    };

    packages = {
      ffmpeg = lib.mkPackageOption pkgs "ffmpeg-headless" { };
      motion = lib.mkPackageOption pkgs "motion" { };
      motioneye = lib.mkPackageOption pkgs "motioneye" { };
    };

    settings = lib.mkOption {
      default = { };

      defaultText = lib.literalExpression /* nix */ ''
        {
          conf_path = lib.mkDefault "/var/lib/motioneye/conf";
          run_path = lib.mkDefault "/run/motioneye";
          log_path = lib.mkDefault "/var/log/motioneye";
          media_path = lib.mkDefault "/var/lib/motioneye/media";
        }
      '';

      description = ''
        Configuration to put in motioneye.conf.
        See <https://github.com/motioneye-project/motioneye/wiki/Configuration-File>  for more details.
      '';

      type = lib.types.attrsOf lib.types.str;
    };

    user = lib.mkOption {
      default = "motioneye";
      description = "User to run motionEye under.";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."motioneye/motioneye.conf".text = lib.concatMapAttrsStringSep "\n" (
      key: value: "${key} ${lib.escapeShellArg value}"
    ) cfg.settings;

    services.motioneye.settings = {
      conf_path = lib.mkDefault "/var/lib/motioneye/conf";
      log_path = lib.mkDefault "/var/log/motioneye";
      media_path = lib.mkDefault "/var/lib/motioneye/media";
      run_path = lib.mkDefault "/run/motioneye";
    };

    # https://github.com/motioneye-project/motioneye/blob/main/motioneye/extra/motioneye.systemd
    systemd.services.motioneye = {
      after = [
        "network.target"
        "local-fs.target"
        "remote-fs.target"
      ];

      description = "motionEye Server";

      path =
        (with pkgs; [
          which
          v4l-utils
        ])
        ++ [
          cfg.packages.motion
          cfg.packages.ffmpeg
        ];

      restartTriggers = [
        config.environment.etc."motioneye/motioneye.conf".source
      ];

      serviceConfig = {
        ExecStart = "${lib.getExe' cfg.packages.motioneye "meyectl"} startserver -c /etc/motioneye/motioneye.conf";
        Group = cfg.group;
        LogsDirectory = "motioneye";
        Restart = "on-abort";
        RuntimeDirectory = "motioneye";
        StateDirectory = "motioneye";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.settings.motioneye =
      let
        config = {
          d = {
            inherit (cfg) user group;
            mode = "0750";
          };
        };
      in
      {
        "${cfg.settings.conf_path}" = config;
        "${cfg.settings.log_path}" = config;
        "${cfg.settings.media_path}" = config;
        "${cfg.settings.run_path}" = config;
      };

    users = {
      groups.${cfg.group} = { };

      users.${cfg.user} = {
        inherit (cfg) group;
        # allow v4l access
        extraGroups = [ "video" ];
        isSystemUser = true;
      };
    };
  };
}
