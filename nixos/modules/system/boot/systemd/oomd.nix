{
  config,
  lib,
  utils,
  ...
}:
let

  cfg = config.systemd.oomd;

in
{
  imports = [
    (lib.mkRenamedOptionModule
      [ "systemd" "oomd" "enableUserServices" ]
      [ "systemd" "oomd" "enableUserSlices" ]
    )
    (lib.mkRenamedOptionModule [ "systemd" "oomd" "extraConfig" ] [ "systemd" "oomd" "settings" "OOM" ])
  ];

  options.systemd.oomd = {
    enable = lib.mkEnableOption "the `systemd-oomd` OOM killer" // {
      default = true;
    };

    # Fedora enables the first and third option by default. See the 10-oomd-* files here:
    # https://src.fedoraproject.org/rpms/systemd/tree/806c95e1c70af18f81d499b24cd7acfa4c36ffd6
    enableRootSlice = lib.mkEnableOption "oomd on the root slice (`-.slice`)";
    enableSystemSlice = lib.mkEnableOption "oomd on the system slice (`system.slice`)";
    enableUserSlices = lib.mkEnableOption "oomd on all user slices (`user@.slice`) and all user owned slices";

    settings.OOM = lib.mkOption {
      default = { };

      description = ''
        Settings option for systemd-oomd.
        See {manpage}`oomd.conf(5)` for available options.
      '';

      example = {
        DefaultMemoryPressureLimit = "60%";
      };

      type = lib.types.submodule {
        freeformType = lib.types.attrsOf utils.systemdUtils.unitOptions.unitOption;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."systemd/oomd.conf".text = utils.systemdUtils.lib.settingsToSections cfg.settings;

    systemd.additionalUpstreamSystemUnits = [
      "systemd-oomd.service"
      "systemd-oomd.socket"
    ];

    systemd.services.systemd-oomd.wantedBy = [ "multi-user.target" ];

    systemd.slices."-".sliceConfig = lib.mkIf cfg.enableRootSlice {
      ManagedOOMMemoryPressure = "kill";
      ManagedOOMMemoryPressureLimit = lib.mkDefault "80%";
    };

    systemd.slices."system".sliceConfig = lib.mkIf cfg.enableSystemSlice {
      ManagedOOMMemoryPressure = "kill";
      ManagedOOMMemoryPressureLimit = lib.mkDefault "80%";
    };

    systemd.slices."user".sliceConfig = lib.mkIf cfg.enableUserSlices {
      ManagedOOMMemoryPressure = "kill";
      ManagedOOMMemoryPressureLimit = lib.mkDefault "80%";
    };

    systemd.user.units."slice" = lib.mkIf cfg.enableUserSlices {
      overrideStrategy = "asDropin";

      text = ''
        [Slice]
        ManagedOOMMemoryPressure=kill
        ManagedOOMMemoryPressureLimit=80%
      '';
    };

    users.groups.systemd-oom = { };

    users.users.systemd-oom = {
      description = "systemd-oomd service user";
      group = "systemd-oom";
      isSystemUser = true;
    };
  };
}
