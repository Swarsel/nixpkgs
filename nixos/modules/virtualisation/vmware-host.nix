{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.virtualisation.vmware.host;
  wrapperDir = "/run/vmware/bin"; # Perfectly fits as /usr/local/bin
  parentWrapperDir = dirOf wrapperDir;
  vmwareWrappers = # Needed as hardcoded paths workaround
    let
      mkVmwareSymlink = program: ''
        ln -s "${config.security.wrapperDir}/${program}" $wrapperDir/${program}
      '';
    in
    [
      (mkVmwareSymlink "pkexec")
      (mkVmwareSymlink "mount")
      (mkVmwareSymlink "umount")
    ];
in
{
  options = with lib; {
    virtualisation.vmware.host = {
      enable = mkEnableOption "VMware" // {
        description = ''
          This enables VMware host virtualisation for running VMs.

          ::: {.important}
          `vmware-vmx` will cause kcompactd0 due to
          `Transparent Hugepages` feature in kernel.
          Apply `[ "transparent_hugepage=never" ]` in
          option {option}`boot.kernelParams` to disable them.
          :::

          ::: {.note}
          If that didn't work disable `TRANSPARENT_HUGEPAGE`,
          `COMPACTION` configs and recompile kernel.
          :::
        '';
      };

      package = mkPackageOption pkgs "vmware-workstation" { };

      extraConfig = mkOption {
        default = "";
        description = "Add extra config to /etc/vmware/config";

        example = ''
          # Allow unsupported device's OpenGL and Vulkan acceleration for guest vGPU
          mks.gl.allowUnsupportedDrivers = "TRUE"
          mks.vk.allowUnsupportedDevices = "TRUE"
        '';

        type = types.lines;
      };

      extraPackages = mkOption {
        default = [ ];
        description = "Extra packages to be used with VMware host.";
        example = "with pkgs; [ ntfs3g ]";
        type = with types; listOf package;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    boot.extraModprobeConfig = "alias char-major-10-229 fuse";
    boot.extraModulePackages = [ config.boot.kernelPackages.vmware ];

    boot.kernelModules = [
      "vmw_pvscsi"
      "vmw_vmci"
      "vmmon"
      "vmnet"
      "fuse"
    ];

    environment.etc."vmware-installer".source = "${cfg.package}/etc/vmware-installer";
    environment.etc."vmware/bootstrap".source = "${cfg.package}/etc/vmware/bootstrap";

    environment.etc."vmware/config".source =
      let
        packageConfig = "${cfg.package}/etc/vmware/config";
      in
      if cfg.extraConfig == "" then
        packageConfig
      else
        pkgs.runCommandLocal "etc-vmware-config"
          {
            inherit packageConfig;
            inherit (cfg) extraConfig;
          }
          ''
            (
              cat "$packageConfig"
              printf "\n"
              echo "$extraConfig"
            ) >"$out"
          '';

    environment.etc."vmware/icu".source = "${cfg.package}/etc/vmware/icu";
    environment.systemPackages = [ cfg.package ] ++ cfg.extraPackages;

    # SUID wrappers
    security.wrappers = {
      vmware-vmx = {
        group = "root";
        owner = "root";
        setuid = true;
        source = "${cfg.package}/lib/vmware/bin/.vmware-vmx-wrapped";
      };
    };

    services.printing.drivers = [ cfg.package ];

    systemd.services."vmware-authdlauncher" = {
      description = "VMware Authentication Daemon";

      serviceConfig = {
        ExecStart = [ "${cfg.package}/bin/vmware-authdlauncher" ];
        Type = "forking";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services."vmware-networks" = {
      after = [ "vmware-networks-configuration.service" ];
      description = "VMware Networks";
      requires = [ "vmware-networks-configuration.service" ];

      serviceConfig = {
        ExecCondition = [ "${pkgs.kmod}/bin/modprobe vmnet" ];
        ExecStart = [ "${cfg.package}/bin/vmware-networks --start" ];
        ExecStop = [ "${cfg.package}/bin/vmware-networks --stop" ];
        Type = "forking";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services."vmware-networks-configuration" = {
      description = "VMware Networks Configuration Generation";

      serviceConfig = {
        ExecStart = [
          "${cfg.package}/bin/vmware-networks --postinstall vmware-player,0,1"
        ];

        RemainAfterExit = "yes";
        Type = "oneshot";
        UMask = "0077";
      };

      unitConfig.ConditionPathExists = "!/etc/vmware/networking";
      wantedBy = [ "multi-user.target" ];
    };

    systemd.services."vmware-usbarbitrator" = {
      description = "VMware USB Arbitrator";

      serviceConfig = {
        ExecStart = [ "${cfg.package}/bin/vmware-usbarbitrator -f" ];
      };

      wantedBy = [ "multi-user.target" ];
    };

    # Services
    systemd.services."vmware-wrappers" = {
      after = [ "systemd-sysusers.service" ];

      before = [
        "vmware-authdlauncher.service"
        "vmware-networks-configuration.service"
        "vmware-networks.service"
        "vmware-usbarbitrator.service"
      ];

      description = "Create VMVare Wrappers";

      script = ''
        mkdir -p "${parentWrapperDir}"
        chmod 755 "${parentWrapperDir}"
        # We want to place the tmpdirs for the wrappers to the parent dir.
        wrapperDir=$(mktemp --directory --tmpdir="${parentWrapperDir}" wrappers.XXXXXXXXXX)
        chmod a+rx "$wrapperDir"
        ${lib.concatStringsSep "\n" vmwareWrappers}
        if [ -L ${wrapperDir} ]; then
          # Atomically replace the symlink
          # See https://axialcorps.com/2013/07/03/atomically-replacing-files-and-directories/
          old=$(readlink -f ${wrapperDir})
          if [ -e "${wrapperDir}-tmp" ]; then
            rm --force --recursive "${wrapperDir}-tmp"
          fi
          ln --symbolic --force --no-dereference "$wrapperDir" "${wrapperDir}-tmp"
          mv --no-target-directory "${wrapperDir}-tmp" "${wrapperDir}"
          rm --force --recursive "$old"
        else
          # For initial setup
          ln --symbolic "$wrapperDir" "${wrapperDir}"
        fi
      '';

      serviceConfig.RemainAfterExit = true;
      serviceConfig.Type = "oneshot";
      wantedBy = [ "multi-user.target" ];
    };
  };
}
