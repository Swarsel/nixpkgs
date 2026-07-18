# Global configuration for atop.

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.atop;

in
{
  ###### interface

  options = {

    programs.atop = {

      enable = lib.mkEnableOption "Atop, a tool for monitoring system resources";
      package = lib.mkPackageOption pkgs "atop" { };

      atopRotateTimer.enable = lib.mkOption {
        default = true;

        description = ''
          Whether to enable the atop-rotate timer, which restarts the atop service
          daily to make sure the data files are rotate.
        '';

        type = lib.types.bool;
      };

      atopService.enable = lib.mkOption {
        default = true;

        description = ''
          Whether to enable the atop service responsible for storing statistics for
          long-term analysis.
        '';

        type = lib.types.bool;
      };

      atopacctService.enable = lib.mkOption {
        default = true;

        description = ''
          Whether to enable the atopacct service which manages process accounting.
          This allows Atop to gather data about processes that disappeared in between
          two refresh intervals.
        '';

        type = lib.types.bool;
      };

      atopgpu.enable = lib.mkOption {
        default = false;

        description = ''
          Whether to install and enable the atopgpud daemon to get information about
          NVIDIA gpus.
        '';

        type = lib.types.bool;
      };

      netatop = {
        enable = lib.mkOption {
          default = false;

          description = ''
            Whether to install and enable the netatop kernel module.
            Note: this sets the kernel taint flag "O" for loading out-of-tree modules.
          '';

          type = lib.types.bool;
        };

        package = lib.mkOption {
          default = config.boot.kernelPackages.netatop;
          defaultText = lib.literalExpression "config.boot.kernelPackages.netatop";

          description = ''
            Which package to use for netatop.
          '';

          type = lib.types.package;
        };
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          Parameters to be written to {file}`/etc/atoprc`.
        '';

        example = {
          flags = "a1f";
          interval = 5;
        };

        type = lib.types.attrs;
      };

      setuidWrapper.enable = lib.mkOption {
        default = false;

        description = ''
          Whether to install a setuid wrapper for Atop. This is required to use some of
          the features as non-root user (e.g.: ipc information, netatop, atopgpu).
          Atop tries to drop the root privileges shortly after starting.
        '';

        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable (
    let
      atop = if cfg.atopgpu.enable then (cfg.package.override { withAtopgpu = true; }) else cfg.package;
    in
    {
      boot.extraModulePackages = [ (lib.mkIf cfg.netatop.enable cfg.netatop.package) ];

      environment.etc = lib.mkIf (cfg.settings != { }) {
        atoprc.text = lib.concatStrings (
          lib.mapAttrsToList (n: v: ''
            ${n} ${toString v}
          '') cfg.settings
        );
      };

      environment.systemPackages = [
        atop
        (lib.mkIf cfg.netatop.enable cfg.netatop.package)
      ];

      security.wrappers = lib.mkIf cfg.setuidWrapper.enable {
        atop = {
          group = "root";
          owner = "root";
          setuid = true;
          source = "${atop}/bin/atop";
        };
      };

      systemd =
        let
          mkSystemd = type: name: restartTriggers: {
            ${name} = {
              inherit restartTriggers;

              wantedBy = [
                (
                  if type == "services" then
                    "multi-user.target"
                  else if type == "timers" then
                    "timers.target"
                  else
                    null
                )
              ];
            };
          };
          mkService = mkSystemd "services";
          mkTimer = mkSystemd "timers";
        in
        {
          packages = [
            atop
            (lib.mkIf cfg.netatop.enable cfg.netatop.package)
          ];

          services = lib.mkMerge [
            (lib.mkIf cfg.atopService.enable (
              lib.recursiveUpdate (mkService "atop" [ atop ]) {
                # always convert logs to newer version first
                # XXX might trigger TimeoutStart but restarting atop.service will
                # convert remainings logs and start eventually
                atop.preStart = ''
                  set -e -u
                  shopt -s nullglob
                  rm -f "$LOGPATH"/atop_*.new
                  for logfile in "$LOGPATH"/atop_*
                  do
                    ${atop}/bin/atopconvert "$logfile" "$logfile".new
                    # only replace old file if version was upgraded to avoid
                    # false positives for atop-rotate.service
                    if ! ${pkgs.diffutils}/bin/cmp -s "$logfile" "$logfile".new
                    then
                      mv -v -f "$logfile".new "$logfile"
                    else
                      rm -f "$logfile".new
                    fi
                  done
                '';
              }
            ))
            (lib.mkIf cfg.atopacctService.enable (mkService "atopacct" [ atop ]))
            (lib.mkIf cfg.netatop.enable (mkService "netatop" [ cfg.netatop.package ]))
            (lib.mkIf cfg.atopgpu.enable (mkService "atopgpu" [ atop ]))
          ];

          timers = lib.mkIf cfg.atopRotateTimer.enable (mkTimer "atop-rotate" [ atop ]);
        };
    }
  );
}
