{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  cfg = config.virtualisation.rosetta;
  inherit (lib) types;
in
{
  options = {
    virtualisation.rosetta.enable = lib.mkOption {
      default = false;

      description = ''
        Whether to enable [Rosetta](https://developer.apple.com/documentation/apple-silicon/about-the-rosetta-translation-environment) support.

        This feature requires the system to be a virtualised guest on an Apple silicon host.

        The default settings are suitable for the [UTM](https://docs.getutm.app/) virtualisation [package](https://search.nixos.org/packages?channel=unstable&show=utm&from=0&size=1&sort=relevance&type=packages&query=utm).
        Make sure to select 'Apple Virtualization' as the virtualisation engine and then tick the 'Enable Rosetta' option.
      '';

      type = types.bool;
    };

    virtualisation.rosetta.mountPoint = lib.mkOption {
      default = "/run/rosetta";

      description = ''
        The mount point for the Rosetta runtime inside the guest system.

        The proprietary runtime is exposed through a VirtioFS directory share and then mounted at this directory.
      '';

      internal = true;
      type = types.str;
    };

    virtualisation.rosetta.mountTag = lib.mkOption {
      default = "rosetta";

      description = ''
        The VirtioFS mount tag for the Rosetta runtime, exposed by the host's virtualisation software.

        If supported, your virtualisation software should provide instructions on how register the Rosetta runtime inside Linux guests.
        These instructions should mention the name of the mount tag used for the VirtioFS directory share that contains the Rosetta runtime.
      '';

      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = pkgs.stdenv.hostPlatform.isAarch64;
        message = "Rosetta is only supported on aarch64 systems";
      }
    ];

    boot.binfmt.registrations.rosetta = {
      # The required flags for binfmt are documented by Apple:
      # https://developer.apple.com/documentation/virtualization/running_intel_binaries_in_linux_vms_with_rosetta
      inherit (utils.binfmtMagics.x86_64-linux) magicOrExtension mask;
      fixBinary = true;
      interpreter = "${cfg.mountPoint}/rosetta";
      matchCredentials = true;
      preserveArgvZero = true;
      # Remove the shell wrapper and call the runtime directly
      wrapInterpreterInShell = false;
    };

    fileSystems."${cfg.mountPoint}" = {
      device = cfg.mountTag;
      fsType = "virtiofs";
    };

    nix.settings = {
      extra-platforms = [ "x86_64-linux" ];

      extra-sandbox-paths = [
        "/run/binfmt"
        cfg.mountPoint
      ];
    };
  };
}
