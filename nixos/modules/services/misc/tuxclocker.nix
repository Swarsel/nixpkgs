{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.tuxclocker;
in
{
  imports = [
    (lib.mkRenamedOptionModule
      [ "programs" "tuxclocker" "enableAMD" ]
      [ "hardware" "amdgpu" "overdrive" "enable" ]
    )
  ];

  options.programs.tuxclocker = {
    enable = lib.mkEnableOption ''
      TuxClocker, a hardware control and monitoring program
    '';

    enabledNVIDIADevices = lib.mkOption {
      default = [ ];

      description = ''
        Enable NVIDIA GPU controls for a device by index.
        Sets the `Coolbits` Xorg option to enable all TuxClocker controls.
      '';

      example = [
        0
        1
      ];

      type = lib.types.listOf lib.types.int;
    };

    useUnfree = lib.mkOption {
      default = false;

      description = ''
        Whether to use components requiring unfree dependencies.
        Disabling this allows you to get everything from the binary cache.
      '';

      example = true;
      type = lib.types.bool;
    };
  };

  config =
    let
      package = if cfg.useUnfree then pkgs.tuxclocker else pkgs.tuxclocker-without-unfree;
    in
    lib.mkIf cfg.enable {
      # MSR is used for some features
      boot.kernelModules = [ "msr" ];

      environment.systemPackages = [
        package
      ];

      services.dbus.packages = [
        package
      ];

      # https://download.nvidia.com/XFree86/Linux-x86_64/430.14/README/xconfigoptions.html#Coolbits
      services.xserver.config =
        let
          configSection = (
            i: ''
              Section "Device"
                Driver "nvidia"
                Option "Coolbits" "31"
                Identifier "Device-nvidia[${toString i}]"
              EndSection
            ''
          );
        in
        lib.concatStrings (map configSection cfg.enabledNVIDIADevices);
    };
}
