{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.security) wrapperDir;
  cfg = config.services.kbfs;

in
{

  ###### interface

  options = {

    services.kbfs = {

      enable = lib.mkOption {
        default = false;
        description = "Whether to mount the Keybase filesystem.";
        type = lib.types.bool;
      };

      enableRedirector = lib.mkOption {
        default = false;

        description = ''
          Whether to enable the Keybase root redirector service, allowing
          any user to access KBFS files via `/keybase`,
          which will show different contents depending on the requester.
        '';

        type = lib.types.bool;
      };

      extraFlags = lib.mkOption {
        default = [ ];

        description = ''
          Additional flags to pass to the Keybase filesystem on launch.
        '';

        example = [
          "-label kbfs"
          "-mount-type normal"
        ];

        type = lib.types.listOf lib.types.str;
      };

      mountPoint = lib.mkOption {
        default = "%h/keybase";
        description = "Mountpoint for the Keybase filesystem.";
        example = "/keybase";
        type = lib.types.str;
      };

    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        environment.systemPackages = [ pkgs.kbfs ];
        services.keybase.enable = true;

        # Upstream: https://github.com/keybase/client/blob/master/packaging/linux/systemd/kbfs.service
        systemd.user.services.kbfs = {
          description = "Keybase File System";
          path = [ "/run/wrappers" ];

          serviceConfig = {
            # Keybase notifies from a forked process
            EnvironmentFile = [
              "-%E/keybase/keybase.autogen.env"
              "-%E/keybase/keybase.env"
            ];

            ExecStart = "${pkgs.kbfs}/bin/kbfsfuse ${toString cfg.extraFlags} \"${cfg.mountPoint}\"";

            ExecStartPre = [
              "${pkgs.coreutils}/bin/mkdir -p \"${cfg.mountPoint}\""
              "-${wrapperDir}/fusermount -uz \"${cfg.mountPoint}\""
            ];

            ExecStop = "${wrapperDir}/fusermount -uz \"${cfg.mountPoint}\"";
            PrivateTmp = true;
            Restart = "on-failure";
            Type = "notify";
          };

          unitConfig.ConditionUser = "!@system";
          wantedBy = [ "default.target" ];
          # Note that the "Requires" directive will cause a unit to be restarted whenever its dependency is restarted.
          # Do not issue a hard dependency on keybase, because kbfs can reconnect to a restarted service.
          # Do not issue a hard dependency on keybase-redirector, because it's ok if it fails (e.g., if it is disabled).
          wants = [ "keybase.service" ] ++ lib.optional cfg.enableRedirector "keybase-redirector.service";
        };
      }

      (lib.mkIf cfg.enableRedirector {
        security.wrappers."keybase-redirector".source = "${pkgs.kbfs}/bin/redirector";

        systemd.tmpfiles.settings."10-kbfs"."/keybase".d = {
          age = "0";
          group = "root";
          mode = "0755";
          user = "root";
        };

        # Upstream: https://github.com/keybase/client/blob/master/packaging/linux/systemd/keybase-redirector.service
        systemd.user.services.keybase-redirector = {
          description = "Keybase Root Redirector for KBFS";

          serviceConfig = {
            EnvironmentFile = [
              "-%E/keybase/keybase.autogen.env"
              "-%E/keybase/keybase.env"
            ];

            # Note: The /keybase mount point is not currently configurable upstream.
            ExecStart = "${wrapperDir}/keybase-redirector /keybase";
            PrivateTmp = true;
            Restart = "on-failure";
          };

          unitConfig.ConditionUser = "!@system";
          wantedBy = [ "default.target" ];
          wants = [ "keybase.service" ];
        };
      })
    ]
  );
}
