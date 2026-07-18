{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.obs-studio;
in
{
  options.programs.obs-studio = {
    enable = lib.mkEnableOption "Free and open source software for video recording and live streaming";

    package = lib.mkPackageOption pkgs "obs-studio" {
      example = "obs-studio";
      nullable = true;
    };

    enableVirtualCamera = lib.mkOption {
      default = false;

      description = ''
        Installs and sets up the v4l2loopback kernel module, necessary for OBS
        to start a virtual camera.
      '';

      type = lib.types.bool;
    };

    finalPackage = lib.mkOption {
      description = "Resulting customized OBS Studio package.";
      readOnly = true;
      type = lib.types.nullOr lib.types.package;
      visible = false;
    };

    plugins = lib.mkOption {
      default = [ ];
      description = "Optional OBS plugins.";
      example = lib.literalExpression "[ pkgs.obs-studio-plugins.wlrobs ]";
      type = lib.types.listOf lib.types.package;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = lib.singleton {
      assertion = cfg.package == null -> cfg.plugins == [ ];
      message = "Plugins cannot be set if package is null";
    };

    boot = lib.mkIf cfg.enableVirtualCamera {
      extraModprobeConfig = ''
        options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
      '';

      extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
      kernelModules = [ "v4l2loopback" ];
    };

    environment.systemPackages = lib.optional (cfg.finalPackage != null) cfg.finalPackage;

    programs.obs-studio.finalPackage = lib.mapNullable (
      obs-studio: pkgs.wrapOBS.override { inherit obs-studio; } { plugins = cfg.plugins; }
    ) cfg.package;

    security.polkit.enable = lib.mkIf cfg.enableVirtualCamera true;
  };

  meta.maintainers = with lib.maintainers; [
    CaptainJawZ
    GaetanLepage
  ];
}
