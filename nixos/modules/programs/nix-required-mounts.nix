{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.nix-required-mounts;
  package = pkgs.nix-required-mounts;

  Mount =
    with lib;
    types.submodule {
      options.guest = mkOption {
        description = "Location in the sandbox to mount the host path at";
        type = types.str;
      };

      options.host = mkOption {
        description = "Host path to mount";
        type = types.str;
      };
    };
  Pattern =
    with lib.types;
    types.submodule (
      { config, name, ... }:
      {
        options.onFeatures = lib.mkOption {
          default = [ name ];
          description = "Which requiredSystemFeatures should trigger relaxation of the sandbox";
          type = listOf types.str;
        };

        options.paths = lib.mkOption {
          description = "A list of glob patterns, indicating which paths to expose to the sandbox";

          type = listOf (oneOf [
            path
            Mount
          ]);
        };

        options.safePrefixes = lib.mkOption {
          default = [ builtins.storeDir ];
          description = "A list of path prefixes that do not need and shall not be searched recursively for further symlink targets. Everything in the nix store does not need to be searched as the derivation already calculcated the full closure of all nix store paths for the drivers package.";
          type = listOf path;
        };

        options.unsafeFollowSymlinks = lib.mkEnableOption ''
          Instructs the hook to mount the symlink targets as well, when any of
          the `paths` contain symlinks. This may not work correctly with glob
          patterns.
        '';
      }
    );

  driverPaths = [
    pkgs.addDriverRunpath.driverLink

    # mesa:
    config.hardware.graphics.package

    # nvidia_x11, etc:
  ]
  ++ config.hardware.graphics.extraPackages; # nvidia_x11

  defaults = {
    nvidia-gpu.onFeatures = package.allowedPatterns.nvidia-gpu.onFeatures;
    nvidia-gpu.paths = package.allowedPatterns.nvidia-gpu.paths ++ driverPaths;
    # TODO: Refactor `hardware.graphics` to ease referencing the closure
    # NOTE: A naive implementation may e.g. introduce a conditional infinite recursion (https://github.com/NixOS/nixpkgs/pull/488199)
    nvidia-gpu.unsafeFollowSymlinks = true;

    zluda = {
      onFeatures = [
        "amd-gpu"
        "cuda"
        "gpu"
        "opengl"
      ];

      paths = [
        pkgs.addDriverRunpath.driverLink
        "/dev/dri"
        "/dev/kfd"
        "/sys/devices/virtual/kfd"
        # As per https://www.kernel.org/doc/Documentation/admin-guide/devices.txt
        # 226 is the major ID for "Direct Rendering Infrastructure (DRI)" devices
        "/sys/dev/char/226:*"
      ]
      ++ config.hardware.graphics.extraPackages;

      unsafeFollowSymlinks = true;
    };
  };
in
{
  options.programs.nix-required-mounts = {
    enable = lib.mkEnableOption "Expose extra paths to the sandbox depending on derivations' requiredSystemFeatures";

    package = lib.mkOption {
      default = package.override { inherit (cfg) allowedPatterns extraWrapperArgs; };
      description = "The final package with the final config applied";
      internal = true;
      type = lib.types.package;
    };

    allowedPatterns =
      with lib.types;
      lib.mkOption {
        default = { };

        defaultText = lib.literalExpression ''
          {
            opengl.paths = config.hardware.graphics.extraPackages ++ [
              config.graphics.opengl.package
              pkgs.addDriverRunpath.driverLink
              "/dev/dri"
            ];
          }
        '';

        description = "The hook config, describing which paths to mount for which system features";
        example.require-ipfs.onFeatures = [ "ipfs" ];
        example.require-ipfs.paths = [ "/ipfs" ];
        type = attrsOf Pattern;
      };

    extraWrapperArgs = lib.mkOption {
      default = [ ];
      description = "List of extra arguments (such as `--add-flags -v`) to pass to the hook's wrapper";
      type = with lib.types; listOf str;
    };

    presets.nvidia-gpu.enable = lib.mkEnableOption ''
      Declare the support for derivations that require an Nvidia GPU to be
      available, e.g. derivations with `requiredSystemFeatures = [ "cuda" ]`.
      This mounts the corresponding userspace drivers and device nodes in the
      sandbox, but only for derivations that request these special features.

      You may extend or override the exposed paths via the
      `programs.nix-required-mounts.allowedPatterns.nvidia-gpu.paths` option.
    '';

    presets.zluda.enable = lib.mkEnableOption ''
      Same as `programs.nix-required-mounts.presets.nvidia-gpu` but adds paths
      to the sandbox that are needed for running CUDA applications on top of
      the ZLUDA translation layer combined with AMD GPUs.

      You may extend or override the exposed paths via the
      `programs.nix-required-mounts.allowedPatterns.zluda.paths` option.
    '';
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      { nix.settings.pre-build-hook = lib.getExe cfg.package; }
      (lib.mkIf cfg.presets.nvidia-gpu.enable {
        hardware.graphics.enable = lib.mkDefault true;
        nix.settings.system-features = cfg.allowedPatterns.nvidia-gpu.onFeatures;

        programs.nix-required-mounts.allowedPatterns = {
          inherit (defaults) nvidia-gpu;
        };
      })
      (lib.mkIf cfg.presets.zluda.enable {
        hardware.amdgpu.zluda.enable = lib.mkDefault true;
        hardware.graphics.enable = lib.mkDefault true;
        nix.settings.system-features = cfg.allowedPatterns.zluda.onFeatures;

        programs.nix-required-mounts.allowedPatterns = {
          inherit (defaults) zluda;
        };
      })
    ]
  );

  meta.maintainers = with lib.maintainers; [ SomeoneSerge ];
}
