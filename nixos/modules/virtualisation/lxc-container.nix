{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./lxc-instance-common.nix

    (lib.mkRemovedOptionModule [
      "virtualisation"
      "lxc"
      "nestedContainer"
    ] "")
    (lib.mkRemovedOptionModule [
      "virtualisation"
      "lxc"
      "privilegedContainer"
    ] "")
  ];

  options = { };

  config =

    {
      boot.isContainer = true;
      image.extension = "tar.xz";
      image.filePath = "tarball/${config.image.fileName}";
      system.build.image = lib.mkOverride 99 config.system.build.tarball;

      system.build.installBootLoader = pkgs.writeScript "install-lxc-sbin-init.sh" ''
        #!${pkgs.runtimeShell}
        ${pkgs.coreutils}/bin/ln -fs "$1/init" /sbin/init
      '';

      system.build.squashfs = pkgs.callPackage ../../lib/make-squashfs.nix {
        comp = "zstd -Xcompression-level 6";
        fileName = "nixos-lxc-image-${pkgs.stdenv.hostPlatform.system}";
        hydraBuildProduct = true;
        noStrip = true; # keep directory structure

        pseudoFiles = [
          "/sbin d 0755 0 0"
          "/sbin/init s 0555 0 0 ${config.system.build.toplevel}/init"
          "/dev d 0755 0 0"
          "/proc d 0555 0 0"
          "/sys d 0555 0 0"
        ];

        storeContents = [ config.system.build.toplevel ];
      };

      system.build.tarball = pkgs.callPackage ../../lib/make-system-tarball.nix {
        contents = [
          {
            source = config.system.build.toplevel + "/init";
            target = "/sbin/init";
          }
          # Technically this is not required for lxc, but having also make this configuration work with systemd-nspawn.
          # Nixos will setup the same symlink after start.
          {
            source = config.system.build.toplevel + "/etc/os-release";
            target = "/etc/os-release";
          }
        ];

        extraArgs = "--owner=0";
        extraCommands = "mkdir -p proc sys dev";
        fileName = config.image.baseName;

        storeContents = [
          {
            object = config.system.build.toplevel;
            symlink = "none";
          }
        ];
      };

      system.nixos.tags = lib.mkOverride 99 [ "lxc" ];
      # networkd depends on this, but systemd module disables this for containers
      systemd.additionalUpstreamSystemUnits = [ "systemd-udev-trigger.service" ];

      # supplement 99-ethernet-default-dhcp which excludes veth
      systemd.network = lib.mkIf config.networking.useDHCP {
        networks."99-lxc-veth-default-dhcp" = {
          DHCP = "yes";

          matchConfig = {
            Kind = "veth";

            Name = [
              "en*"
              "eth*"
            ];

            Type = "ether";
          };

          networkConfig.IPv6PrivacyExtensions = "kernel";
        };
      };

      systemd.packages = [ pkgs.distrobuilder.generator ];

      systemd.services.register-nix-paths = {
        after = [ "local-fs.target" ];

        before = [
          "sysinit.target"
          "shutdown.target"
          "nix-daemon.socket"
          "nix-daemon.service"
        ];

        conflicts = [ "shutdown.target" ];
        description = "Register Nix Store Paths";
        restartIfChanged = false;

        script = ''
          ${lib.getExe' config.nix.package.out "nix-store"} --load-db < /nix-path-registration
          rm /nix-path-registration

          # nixos-rebuild also requires a "system" profile
          ${lib.getExe' config.nix.package.out "nix-env"} -p /nix/var/nix/profiles/system --set /run/current-system
        '';

        serviceConfig = {
          RemainAfterExit = true;
          Type = "oneshot";
        };

        unitConfig = {
          ConditionPathExists = "/nix-path-registration";
          DefaultDependencies = false;
        };

        wantedBy = [ "sysinit.target" ];
      };

    };

  meta = {
    teams = [ lib.teams.lxc ];
  };
}
