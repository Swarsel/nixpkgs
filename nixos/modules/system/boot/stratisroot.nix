{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  requiredStratisFilesystems = lib.attrsets.filterAttrs (
    _: x: utils.fsNeededForBoot x && x.stratis.poolUuid != null
  ) config.fileSystems;
in
{
  options = { };

  config = lib.mkIf (requiredStratisFilesystems != { }) {
    assertions = [
      {
        assertion = config.boot.initrd.systemd.enable;
        message = "stratis root fs requires systemd stage 1";
      }
    ];

    boot.initrd = {
      availableKernelModules = [
        "dm-thin-pool"
        "dm-crypt"
      ]
      ++ [
        "aes"
        "blowfish"
        "twofish"
        "serpent"
        "cbc"
        "xts"
        "lrw"
        "sha1"
        "sha256"
        "sha512"
        "af_alg"
        "algif_skcipher"
      ];

      services.udev.packages = [
        pkgs.stratisd.initrd
        pkgs.lvm2
      ];

      systemd = {
        extraBin = {
          stratis-min = "${pkgs.stratisd}/bin/stratis-min";
          thin_check = "${pkgs."thin-provisioning-tools"}/bin/thin_check";
          thin_metadata_size = "${pkgs."thin-provisioning-tools"}/bin/thin_metadata_size";
          thin_repair = "${pkgs."thin-provisioning-tools"}/bin/thin_repair";
        };

        packages = [ pkgs.stratisd.initrd ];

        services = lib.attrsets.mapAttrs' (mountPoint: fileSystem: {
          name = "stratis-setup-${fileSystem.stratis.poolUuid}";

          value = {
            after = [
              "paths.target"
              "plymouth-start.service"
              "stratisd-min.service"
            ];

            before = [
              "initrd.target"
              "shutdown.target"
              "initrd-switch-root.target"
            ];

            conflicts = [
              "shutdown.target"
              "initrd-switch-root.target"
            ];

            description = "setup for Stratis root filesystem";
            environment.STRATIS_ROOTFS_UUID = fileSystem.stratis.poolUuid;
            onFailure = [ "emergency.target" ];

            serviceConfig = {
              ExecStart = "${pkgs.stratisd.initrd}/bin/stratis-rootfs-setup";
              RemainAfterExit = "yes";
              Type = "oneshot";
            };

            unitConfig.DefaultDependencies = "no";
            unitConfig.OnFailureJobMode = "isolate";
            wantedBy = [ "initrd.target" ];

            wants = [
              "stratisd-min.service"
              "plymouth-start.service"
            ];
          };
        }) requiredStratisFilesystems;

        storePaths = [
          "${pkgs.stratisd}/lib/udev/stratis-base32-decode"
          "${pkgs.stratisd}/lib/udev/stratis-str-cmp"
          "${pkgs.lvm2.bin}/bin/dmsetup"
          "${pkgs.stratisd}/libexec/stratisd-min"
          "${pkgs.stratisd.initrd}/bin/stratis-rootfs-setup"
        ];
      };
    };
  };
}
