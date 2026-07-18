# This module creates a lightweight "container" from the NixOS configuration.
# Building the `config.system.build.nspawn` attribute gives you a command
# that starts a systemd-nspawn container running the NixOS configuration
# defined in `config`. By default, the Nix store is shared read-only with the
# host, which makes (re)building very efficient.
# This shares a lot in common with
# `nixos/modules/virtualisation/nixos-containers.nix`, but doesn't use systemd
# units.
# The networking options here match the options in
# `nixos/modules/virtualisation/nixos-containers.nix` which allows using these
# lightweight containers for nixos integration tests.

{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types;
  cfg = config.virtualisation;
in
{
  imports = [
    ../credentials-options.nix
  ];

  options = {

    virtualisation.cmdline = lib.mkOption {
      default = [ ];

      description = ''
        Command line arguments to pass to the init process (likely systemd).
        Useful for debugging.
      '';

      example = [
        "systemd.unit=rescue.target"
        "systemd.log_level=debug"
        "systemd.log_target=console"
      ];

      type = types.listOf types.str;
    };

    virtualisation.rootDir = lib.mkOption {
      default = "./${config.system.name}-root";
      defaultText = lib.literalExpression ''"./''${config.system.name}-root"'';

      description = ''
        Path to a directory for the root filesystem for the container.
        The directory will be created on startup if it does not
        exist.
      '';

      type = types.str;
    };

    virtualisation.systemd-nspawn = {

      options = lib.mkOption {
        default = [ ];

        description = ''
          Options passed to systemd-nspawn.
          See [systemd-nspawn docs](https://www.freedesktop.org/software/systemd/man/latest/systemd-nspawn.html) for a complete list.
        '';

        example = [ "--bind=/home:/home" ];
        type = types.listOf types.str;
      };

      package = lib.mkPackageOption pkgs "systemd" { };

    };
  };

  config = {
    assertions = [
      {
        assertion = config.specialisation == { };

        message = ''
          Setting 'specialisation' is disallowed for systemd-nspawn container configurations.
          Activating a specialisation requires creating SUID wrappers (e.g., for 'sudo'),
          which is prohibited within the Nix build sandbox where the test is run.
        '';
      }
      {
        # Check every interface defined in allInterfaces.
        # Containers try to create a bridge "${config.system.name}-${interfaceName}"
        assertion = lib.all (
          iface:
          let
            hostName = "${config.system.name}-${iface.name}";
          in
          lib.stringLength hostName <= 15
        ) (lib.attrValues cfg.allInterfaces);

        message =
          let
            offendingInterfaces = lib.filter (
              iface: lib.stringLength "${config.system.name}-${iface.name}" > 15
            ) (lib.attrValues cfg.allInterfaces);
            offenderList = map (
              i:
              "${config.system.name}-${i.name} (${toString (lib.stringLength "${config.system.name}-${i.name}")} chars)"
            ) offendingInterfaces;
          in
          ''
            The following generated host interface names exceed the Linux 15-character limit:
              ${lib.concatStringsSep "\n            " offenderList}

            Please shorten 'config.system.name' or the interface names in 'virtualisation.interfaces'.
          '';
      }
    ];

    boot.isNspawnContainer = true;

    system.build.nspawn =
      let
        run-nspawn = pkgs.callPackage ./run-nspawn { };
        commandLineOptions = lib.cli.toCommandLineShellGNU { } {
          cmdline-json = builtins.toJSON cfg.cmdline;
          container-name = config.system.name;
          init = "${config.system.build.toplevel}/init";
          interfaces-json = builtins.toJSON (lib.attrValues cfg.allInterfaces);
          root-dir = cfg.rootDir;
        };
      in
      pkgs.writers.writeDashBin "run-${config.system.name}-nspawn" ''
        exec ${lib.getExe run-nspawn} ${commandLineOptions} ${lib.escapeShellArgs config.virtualisation.systemd-nspawn.options} "$@"
      '';

    virtualisation.systemd-nspawn.options = [
      "--private-network"
      "--machine=${config.system.name}"
      "--bind-ro=/nix/store:/nix/store"

      # systemd-nspawn does some cleverness to mount a procfs and sysfs in an
      # unprivileged container, see
      # <https://github.com/systemd/systemd/blob/v258.2/src/nspawn/nspawn.c#L4341-L4349>.
      # Unfortunately, this doesn't work in the Nix build sandbox as we do not
      # have permission to mount filesystems of type `sysfs` nor `procfs`.
      # Fortunately, the build sandbox does provide a `/proc` and `/sys` that
      # we can just forward onto the container.
      "--private-users=no"
      "--bind=/proc:/run/host/proc"
      "--bind=/sys:/run/host/sys"

      # From `man systemd-nspawn`:
      # > Use --keep-unit and --register=no in combination to disable any
      # > kind of unit allocation or registration with systemd-machined.
      "--keep-unit"
      "--register=no"

      # Send a READY=1 notification to a socket when the container is fully booted.
      "--notify-ready=yes"
    ]
    ++ lib.mapAttrsToList (name: cred: "--load-credential=${name}:${cred.source}") cfg.credentials;
  };
}
