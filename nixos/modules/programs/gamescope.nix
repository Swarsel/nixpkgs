{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.gamescope;

  gamescope =
    let
      wrapperArgs =
        lib.optional (cfg.args != [ ]) ''--add-flags "${toString cfg.args}"''
        ++ builtins.attrValues (builtins.mapAttrs (var: val: "--set-default ${var} ${val}") cfg.env);
    in
    pkgs.runCommand "gamescope" { nativeBuildInputs = [ pkgs.makeBinaryWrapper ]; } ''
      mkdir -p $out/bin
      makeWrapper ${cfg.package}/bin/gamescope $out/bin/gamescope --inherit-argv0 \
        ${toString wrapperArgs}
      ln -s ${cfg.package}/bin/gamescopectl $out/bin/gamescopectl
    '';
in
{
  options.programs.gamescope = {
    enable = lib.mkEnableOption "gamescope, the SteamOS session compositing window manager";
    package = lib.mkPackageOption pkgs "gamescope" { };

    args = lib.mkOption {
      default = [ ];

      description = ''
        Arguments passed to GameScope on startup.
      '';

      example = [
        "--rt"
        "--prefer-vk-device 8086:9bc4"
      ];

      type = lib.types.listOf lib.types.str;
    };

    capSysNice = lib.mkOption {
      default = false;

      description = ''
        Add cap_sys_nice capability to the GameScope
        binary so that it may renice itself.
      '';

      type = lib.types.bool;
    };

    enableWsi = lib.mkEnableOption "gamescope-wsi, the Vulkan WSI layer, alongside gamescope";

    env = lib.mkOption {
      default = { };

      description = ''
        Default environment variables available to the GameScope process, overridable at runtime.
      '';

      example = lib.literalExpression ''
        # for Prime render offload on Nvidia laptops.
        # Also requires `hardware.nvidia.prime.offload.enable`.
        {
          __NV_PRIME_RENDER_OFFLOAD = "1";
          __VK_LAYER_NV_optimus = "NVIDIA_only";
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        }
      '';

      type = lib.types.attrsOf lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = lib.mkIf (!cfg.capSysNice) [ gamescope ];

    hardware.graphics = lib.optionalAttrs cfg.enableWsi {
      extraPackages = with pkgs; [ gamescope-wsi ];
      extraPackages32 = with pkgs; [ pkgsi686Linux.gamescope-wsi ];
    };

    security.wrappers = lib.mkIf cfg.capSysNice {
      gamescope = {
        capabilities = "cap_sys_nice+pie";
        group = "root";
        owner = "root";
        source = "${gamescope}/bin/gamescope";
      };
    };
  };

  meta.maintainers = [ ];
}
