{
  config,
  lib,
  options,
  ...
}:
let
  inherit (config.hardware.facter) report;
  cfg = config.hardware.facter.detected.virtualisation;
in
{
  options.hardware.facter.detected.virtualisation = {
    hyperv.enable = lib.mkEnableOption "Enable the Facter Virtualisation Hyper-V module" // {
      default = report.virtualisation or null == "microsoft";
      defaultText = "environment dependent";
    };

    # no virtualisation detected
    none.enable = lib.mkEnableOption "Enable the Facter Virtualisation None module" // {
      default = report.virtualisation or null == "none";
      defaultText = "environment dependent";
    };

    oracle.enable = lib.mkEnableOption "Enable the Facter Virtualisation Oracle module" // {
      default = report.virtualisation or null == "oracle";
      defaultText = "environment dependent";
    };

    parallels.enable = lib.mkEnableOption "Enable the Facter Virtualisation Parallels module" // {
      default = report.virtualisation or null == "parallels";
      defaultText = "environment dependent";
    };

    qemu.enable = lib.mkEnableOption "Enable the Facter Virtualisation Qemu module" // {
      default = builtins.elem (report.virtualisation or null) [
        "qemu"
        "kvm"
        "bochs"
      ];

      defaultText = "environment dependent";
    };

    virtio_scsi.enable = lib.mkEnableOption "Enable the Facter Virtualisation Virtio SCSI module" // {
      default = lib.any (
        { device, vendor, ... }:
        # vendor (0x1af4) Red Hat, Inc.
        (vendor.value or 0) == 6900
        &&
          # device (0x1004, 0x1048) Virtio SCSI
          (lib.elem (device.value or 0) [
            4100
            4168
          ])
      ) (report.hardware.scsi or [ ]);

      defaultText = "hardware dependent";
    };
  };

  config = lib.mkIf config.hardware.facter.enable {

    # virtio & qemu
    boot.initrd = {
      availableKernelModules = lib.mkMerge [
        (lib.mkIf cfg.qemu.enable [
          "virtio_net"
          "virtio_pci"
          "virtio_mmio"
          "virtio_blk"
          "9p"
          "9pnet_virtio"
        ])
        (lib.mkIf cfg.virtio_scsi.enable [
          "virtio_scsi"
        ])
      ];

      kernelModules = lib.optionals cfg.qemu.enable [
        "virtio_balloon"
        "virtio_console"
        "virtio_rng"
        "virtio_gpu"
      ];
    };

    # KVM support
    boot.kernelModules =
      let
        hasCPUFeature =
          feature:
          lib.any (
            {
              features ? [ ],
              ...
            }:
            lib.elem feature features
          ) (report.hardware.cpu or [ ]);
      in
      lib.mkMerge [
        (lib.mkIf (hasCPUFeature "vmx") [ "kvm-intel" ])
        (lib.mkIf (hasCPUFeature "svm") [ "kvm-amd" ])
      ];

    # parallels
    hardware.parallels.enable = lib.mkIf cfg.parallels.enable (lib.mkDefault true);

    nixpkgs.config = lib.mkIf (!options.nixpkgs.pkgs.isDefined && cfg.parallels.enable) {
      allowUnfreePackages = [ "prl-tools" ];
    };

    virtualisation = {
      # hyper-v
      hypervGuest.enable = lib.mkIf cfg.hyperv.enable (lib.mkDefault true);
      # oracle
      virtualbox.guest.enable = lib.mkIf cfg.oracle.enable (lib.mkDefault true);
    };
  };
}
