{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    getExe'
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    types
    ;

  cfg = config.services.tee-supplicant;

  taDir = "optee_armtz";

  trustedApplications = pkgs.linkFarm "runtime-trusted-applications" (
    map (
      ta:
      let
        # This is safe since we are using it as the path value, so the context
        # will still ensure that this nix store path exists on the running
        # system.
        taFile = baseNameOf (builtins.unsafeDiscardStringContext ta);
      in
      {
        name = "lib/${taDir}/${taFile}";
        path = ta;
      }
    ) cfg.trustedApplications
  );
in
{
  options.services.tee-supplicant = {
    enable = mkEnableOption "OP-TEE userspace supplicant";
    package = mkPackageOption pkgs "optee-client" { };

    pluginPath = mkOption {
      default = "/run/current-system/sw/lib/tee-supplicant/plugins";

      description = ''
        The directory where plugins will be loaded from on startup.
      '';

      type = types.path;
    };

    reeFsParentPath = mkOption {
      default = "/var/lib/tee";

      description = ''
        The directory where the secure filesystem will be stored in the rich
        execution environment (REE FS).
      '';

      type = types.path;
    };

    trustedApplications = mkOption {
      default = [ ];

      description = ''
        A list of full paths to trusted applications that will be loaded at
        runtime by tee-supplicant.
      '';

      type = types.listOf types.path;
    };
  };

  config = mkIf cfg.enable {
    environment = mkIf (cfg.trustedApplications != [ ]) {
      pathsToLink = [ "/lib/${taDir}" ];
      systemPackages = [ trustedApplications ];
    };

    systemd.services.tee-supplicant = {
      after = [ "modprobe@optee.service" ];
      description = "Userspace supplicant for OPTEE-OS";

      serviceConfig = {
        ExecStart = toString [
          (getExe' cfg.package "tee-supplicant")
          "--ta-dir ${taDir}"
          "--fs-parent-path ${cfg.reeFsParentPath}"
          "--plugin-path ${cfg.pluginPath}"
        ];

        Restart = "always";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "modprobe@optee.service" ];
    };
  };
}
