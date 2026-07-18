{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.hardware.amdgpu;
in
{
  options.hardware.amdgpu = {
    initrd.enable = lib.mkEnableOption ''
      loading `amdgpu` kernelModule in stage 1.
      Can fix lower resolution in boot screen during initramfs phase
    '';

    legacySupport.enable = lib.mkEnableOption ''
      using `amdgpu` kernel driver instead of `radeon` for Southern Islands
      (Radeon HD 7000) series and Sea Islands (Radeon HD 8000)
      series cards. Note: this removes support for analog video outputs,
      which is only available in the `radeon` driver
    '';

    opencl.enable = lib.mkEnableOption "OpenCL support using ROCM runtime library";

    overdrive = {
      enable = lib.mkEnableOption "`amdgpu` overdrive mode for overclocking";

      ppfeaturemask = lib.mkOption {
        default = "0xfffd7fff";

        description = ''
          Sets the `amdgpu.ppfeaturemask` kernel option. It can be used to enable the overdrive bit.
          Default is `0xfffd7fff` as it is less likely to cause flicker issues. Setting it to
          `0xffffffff` enables all features, but also can be unstable. See
          [the kernel documentation](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/gpu/drm/amd/include/amd_shared.h#n169)
          for more information.
        '';

        example = "0xffffffff";
        type = lib.types.str;
      };
    };

    zluda.enable = lib.mkEnableOption "CUDA support using ZLUDA runtime library";
    zluda.package = lib.mkPackageOption pkgs "zluda" { };
  };

  config = lib.mkMerge [
    {
      boot.initrd.kernelModules = lib.optionals cfg.initrd.enable [ "amdgpu" ];

      boot.kernelParams =
        lib.optionals cfg.legacySupport.enable [
          "amdgpu.si_support=1"
          "amdgpu.cik_support=1"
          "radeon.si_support=0"
          "radeon.cik_support=0"
        ]
        ++ lib.optionals cfg.overdrive.enable [
          "amdgpu.ppfeaturemask=${cfg.overdrive.ppfeaturemask}"
        ];
    }
    (lib.mkIf cfg.opencl.enable {
      hardware.graphics = {
        enable = lib.mkDefault true;

        extraPackages = [
          pkgs.rocmPackages.clr
          pkgs.rocmPackages.clr.icd
        ];
      };
    })
    (lib.mkIf cfg.zluda.enable {
      hardware.graphics = {
        enable = lib.mkDefault true;
        extraPackages = [ cfg.zluda.package ];
      };
    })
  ];

  meta = {
    maintainers = with lib.maintainers; [ johnrtitor ];
  };
}
