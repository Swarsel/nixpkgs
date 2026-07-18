{
  config,
  lib,
  ...
}:

{

  imports = [ ./etc.nix ];

  config = lib.mkMerge [

    {
      system.activationScripts.etc = lib.stringAfter [
        "users"
        "groups"
        "specialfs"
      ] config.system.build.etcActivationCommands;
    }

    (lib.mkIf config.system.etc.overlay.enable {

      assertions = [
        {
          assertion = config.boot.initrd.systemd.enable;
          message = "`system.etc.overlay.enable` requires `boot.initrd.systemd.enable`";
        }
        {
          assertion =
            (!config.system.etc.overlay.mutable)
            -> (config.systemd.sysusers.enable || config.services.userborn.enable);

          message = "`!system.etc.overlay.mutable` requires `systemd.sysusers.enable` or `services.userborn.enable`";
        }
        {
          assertion =
            (config.system.switch.enable)
            -> (lib.versionAtLeast config.boot.kernelPackages.kernel.version "6.6");

          message = "switchable systems with `system.etc.overlay.enable` require a newer kernel, at least version 6.6";
        }
      ];

      boot.initrd.availableKernelModules = [
        "loop"
        "erofs"
        "overlay"
      ];

      boot.initrd.systemd = {
        mounts = [
          {
            options = "loop,ro,nodev,nosuid";

            after = [
              config.boot.initrd.systemd.services.initrd-find-etc.name
            ];

            before = [ "initrd-fs.target" ];
            requiredBy = [ "initrd-fs.target" ];

            requires = [
              config.boot.initrd.systemd.services.initrd-find-etc.name
            ];

            type = "erofs";

            unitConfig = {
              # find-etc only creates this symlink for a NixOS init. For a
              # non-NixOS init= (e.g. init=/bin/sh) it is absent, so skip the
              # mount instead of failing the whole initrd.
              ConditionPathExists = "/etc-metadata-image";
              # Since this unit depends on the nix store being mounted, it cannot
              # be a dependency of local-fs.target, because if it did, we'd have
              # local-fs.target ordered after the nix store mount which would cause
              # things like network.target to only become active after the nix store
              # has been mounted.
              # This breaks for instance setups where sshd needs to be up before
              # any encrypted disks can be mounted.
              DefaultDependencies = false;

              RequiresMountsFor = [
                "/sysroot/nix/store"
              ];
            };

            what = "/etc-metadata-image";
            where = "/run/nixos-etc-metadata";
          }
          {
            options = lib.concatStringsSep "," (
              [
                "nodev"
                "nosuid"
                "relatime"
                "redirect_dir=on"
                "metacopy=on"
                "lowerdir=/run/nixos-etc-metadata::/etc-basedir"
              ]
              ++ lib.optionals config.system.etc.overlay.mutable [
                "rw"
                "upperdir=/sysroot/.rw-etc/upper"
                "workdir=/sysroot/.rw-etc/work"
              ]
              ++ lib.optionals (!config.system.etc.overlay.mutable) [
                "ro"
              ]
            );

            after = [
              config.boot.initrd.systemd.services.initrd-find-etc.name
            ]
            ++ lib.optionals config.system.etc.overlay.mutable [
              config.boot.initrd.systemd.services."rw-etc".name
            ];

            before = [ "initrd-fs.target" ];
            requiredBy = [ "initrd-fs.target" ];

            requires = [
              config.boot.initrd.systemd.services.initrd-find-etc.name
            ]
            ++ lib.optionals config.system.etc.overlay.mutable [
              config.boot.initrd.systemd.services."rw-etc".name
            ];

            type = "overlay";

            unitConfig = {
              # Skip for a non-NixOS init=, see the metadata mount above.
              ConditionPathExists = "/etc-basedir";
              DefaultDependencies = false;

              RequiresMountsFor = [
                "/sysroot/nix/store"
                "/run/nixos-etc-metadata"
              ];
            };

            what = "overlay";
            where = "/sysroot/etc";
          }
        ];

        services = lib.mkMerge [
          (lib.mkIf config.system.etc.overlay.mutable {
            rw-etc = {
              before = [ "initrd-fs.target" ];
              requiredBy = [ "initrd-fs.target" ];

              serviceConfig = {
                ExecStart = [
                  "/bin/mkdir -p -m 0755 /sysroot/.rw-etc/upper /sysroot/.rw-etc/work"
                  "${config.system.nixos-init.package}/bin/clear-etc-opaque /run/nixos-etc-metadata /sysroot/.rw-etc/upper"
                ];

                Type = "oneshot";
              };

              unitConfig = {
                # Skip for a non-NixOS init=, see the metadata mount above.
                ConditionPathExists = "/etc-metadata-image";
                DefaultDependencies = false;

                RequiresMountsFor = [
                  "/sysroot"
                  # Needed so we can clear stale opaque markers from the
                  # upperdir based on the contents of the new metadata layer
                  # before the overlay is mounted.
                  "/run/nixos-etc-metadata"
                ];
              };
            };
          })
          {
            initrd-find-etc = {
              before = [ "shutdown.target" ];
              conflicts = [ "shutdown.target" ];
              description = "Find the path to the etc metadata image and based dir";
              path = [ config.system.nixos-init.package ];
              requiredBy = [ "initrd.target" ];

              serviceConfig = {
                ExecStart = "${config.system.nixos-init.package}/bin/find-etc";
                RemainAfterExit = true;
                Type = "oneshot";
              };

              unitConfig = {
                DefaultDependencies = false;
                RequiresMountsFor = "/sysroot/nix/store";
              };
            };
          }
        ];

        storePaths = lib.mkIf config.system.etc.overlay.mutable [
          "${config.system.nixos-init.package}/bin/clear-etc-opaque"
        ];
      };

      system.requiredKernelConfig = with config.lib.kernelConfig; [
        (isEnabled "EROFS_FS")
      ];

    })

    (lib.mkIf (config.system.etc.overlay.enable && !config.system.etc.overlay.mutable) {
      # An empty regular file means systemd will bind mount /run/machine-id
      # on top, and ConditionFirstBoot will be false (the file will never
      # change, so this makes sense). See machine-id(5) "First Boot
      # Semantics". It also serves as a target to bind mount an actually
      # persistent machine-id onto. A symlink doesn't work here since
      # systemd-machine-id-commit checks /etc/machine-id itself for being a
      # mountpoint without following symlinks, so it would never commit
      # through a symlink.
      environment.etc.machine-id = lib.mkDefault {
        mode = "0444";
        text = "";
      };

      # The upstream unit has ConditionPathIsReadWrite=/etc, which is always
      # false here. Replace it with ConditionFirstBoot: with the empty
      # placeholder above first-boot is "no" and commit stays skipped, but
      # when a persistence module bind-mounts a writable file containing
      # "uninitialized" over /etc/machine-id, first-boot is "yes" once and
      # commit writes the generated ID through the bind mount.
      #
      # An empty Condition*= assignment resets *all* condition types, and
      # this attrset is serialised in key order, so the reset goes through
      # ConditionFirstBoot (sorts first) and we re-add the upstream
      # ConditionPathIsMountPoint afterwards.
      systemd.services.systemd-machine-id-commit.unitConfig = {
        ConditionFirstBoot = lib.mkDefault [
          ""
          "true"
        ];

        ConditionPathIsMountPoint = lib.mkDefault "/etc/machine-id";
      };
    })

  ];
}
