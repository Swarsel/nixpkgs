# fwupd daemon.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.fwupd;

  format = pkgs.formats.ini {
    listToValue = l: lib.concatStringsSep ";" (map (s: lib.generators.mkValueStringDefault { } s) l);
    mkKeyValue = lib.generators.mkKeyValueDefault { } "=";
  };

  customEtc = {
    "fwupd/fwupd.conf" = {
      # fwupd tries to chmod the file if it doesn't have the right permissions
      mode = "0640";

      source = format.generate "fwupd.conf" (
        {
          fwupd = cfg.daemonSettings;
        }
        // lib.optionalAttrs (lib.length (lib.attrNames cfg.uefiCapsuleSettings) != 0) {
          uefi_capsule = cfg.uefiCapsuleSettings;
        }
      );
    };
  };

  originalEtc =
    let
      mkEtcFile = n: lib.nameValuePair n { source = "${cfg.package}/etc/${n}"; };
    in
    lib.listToAttrs (map mkEtcFile cfg.package.filesInstalledToEtc);
  extraTrustedKeys =
    let
      mkName = p: "pki/fwupd/${baseNameOf p}";
      mkEtcFile = p: lib.nameValuePair (mkName p) { source = p; };
    in
    lib.listToAttrs (map mkEtcFile cfg.extraTrustedKeys);

  enableRemote = base: remote: {
    "fwupd/remotes.d/${remote}.conf" = {
      source = pkgs.runCommand "${remote}-enabled.conf" { } ''
        sed "s,^Enabled=false,Enabled=true," \
        "${base}/etc/fwupd/remotes.d/${remote}.conf" > "$out"
      '';
    };
  };
  remotes =
    (lib.foldl' (
      configFiles: remote: configFiles // (enableRemote cfg.package remote)
    ) { } cfg.extraRemotes)
    // (
      # We cannot include the file in $out and rely on filesInstalledToEtc
      # to install it because it would create a cyclic dependency between
      # the outputs. We also need to enable the remote,
      # which should not be done by default.
      lib.optionalAttrs (cfg.daemonSettings.TestDevices or false) (
        enableRemote cfg.package.installedTests "fwupd-tests"
      )
    );

in
{

  imports = [
    (lib.mkRenamedOptionModule
      [ "services" "fwupd" "blacklistDevices" ]
      [ "services" "fwupd" "daemonSettings" "DisabledDevices" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "fwupd" "blacklistPlugins" ]
      [ "services" "fwupd" "daemonSettings" "DisabledPlugins" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "fwupd" "disabledDevices" ]
      [ "services" "fwupd" "daemonSettings" "DisabledDevices" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "fwupd" "disabledPlugins" ]
      [ "services" "fwupd" "daemonSettings" "DisabledPlugins" ]
    )
    (lib.mkRemovedOptionModule [ "services" "fwupd" "enableTestRemote" ]
      "This option was removed after being removed upstream. It only provided a method for testing fwupd functionality, and should not have been exposed for use outside of nix tests."
    )
  ];

  ###### interface
  options = {
    services.fwupd = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable fwupd, a DBus service that allows
          applications to update firmware.
        '';

        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "fwupd" { };

      daemonSettings = lib.mkOption {
        default = { };

        description = ''
          Configurations for the fwupd daemon.
        '';

        type = lib.types.submodule {
          options = {
            DisabledDevices = lib.mkOption {
              default = [ ];

              description = ''
                List of device GUIDs to be disabled.
              '';

              example = [ "2082b5e0-7a64-478a-b1b2-e3404fab6dad" ];
              type = lib.types.listOf lib.types.str;
            };

            DisabledPlugins = lib.mkOption {
              default = [ ];

              description = ''
                List of plugins to be disabled.
              '';

              example = [ "udev" ];
              type = lib.types.listOf lib.types.str;
            };

            EspLocation = lib.mkOption {
              default = config.boot.loader.efi.efiSysMountPoint;
              defaultText = lib.literalExpression "config.boot.loader.efi.efiSysMountPoint";

              description = ''
                The EFI system partition (ESP) path used if UDisks is not available
                or if this partition is not mounted at /boot/efi, /boot, or /efi
              '';

              type = lib.types.path;
            };

            TestDevices = lib.mkOption {
              default = false;

              description = ''
                Create virtual test devices and remote for validating daemon flows.
                This is only intended for CI testing and development purposes.
              '';

              internal = true;
              type = lib.types.bool;
            };
          };

          freeformType = format.type.nestedTypes.elemType;
        };
      };

      extraRemotes = lib.mkOption {
        default = [ ];

        description = ''
          Enables extra remotes in fwupd. See `/etc/fwupd/remotes.d`.
        '';

        example = [ "lvfs-testing" ];
        type = with lib.types; listOf str;
      };

      extraTrustedKeys = lib.mkOption {
        default = [ ];

        description = ''
          Installing a public key allows firmware signed with a matching private key to be recognized as trusted, which may require less authentication to install than for untrusted files. By default trusted firmware can be upgraded (but not downgraded) without the user or administrator password. Only very few keys are installed by default.
        '';

        example = lib.literalExpression "[ /etc/nixos/fwupd/myfirmware.pem ]";
        type = lib.types.listOf lib.types.path;
      };

      uefiCapsuleSettings = lib.mkOption {
        default = { };

        description = ''
          UEFI capsule configurations for the fwupd daemon.
        '';

        type = lib.types.submodule {
          freeformType = format.type.nestedTypes.elemType;
        };
      };
    };
  };

  ###### implementation
  config = lib.mkIf cfg.enable {
    # customEtc overrides some files from the package
    environment.etc = originalEtc // customEtc // extraTrustedKeys // remotes;
    environment.systemPackages = [ cfg.package ];

    security.polkit = {
      enable = true;

      # fwupd-refresh.service has no seat, so polkit denies these actions.
      # Upstream's TrustedUids needs a static uid which we only allocate at
      # activation time, so grant access via a rule on the user name instead.
      extraConfig = ''
        polkit.addRule(function(action, subject) {
          if ((action.id == "org.freedesktop.fwupd.get-remotes" ||
               action.id == "org.freedesktop.fwupd.refresh-remote") &&
              subject.user == "fwupd-refresh") {
            return polkit.Result.YES;
          }
        });
      '';
    };

    services.dbus.packages = [ cfg.package ];

    # Disable test related plug-ins implicitly so that users do not have to care about them.
    services.fwupd.daemonSettings = {
      EspLocation = config.boot.loader.efi.efiSysMountPoint;
    };

    services.udev.packages = [ cfg.package ];
    # required to update the firmware of disks
    services.udisks2.enable = true;

    systemd = {
      packages = [ cfg.package ];

      # The upstream unit runs as User=fwupd-refresh; ensure it can take
      # ownership of /var/lib/fwupd.
      services.fwupd-refresh.serviceConfig = {
        # Better for debugging, upstream sets stderr to null for some reason..
        StandardError = "inherit";
        StateDirectory = "fwupd";
      };

      timers.fwupd-refresh.wantedBy = [ "timers.target" ];
    };

    users.groups.fwupd-refresh = { };

    users.users.fwupd-refresh = {
      group = "fwupd-refresh";
      isSystemUser = true;
    };
  };

  meta = {
    maintainers = pkgs.fwupd.meta.maintainers;
  };
}
