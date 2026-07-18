{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.services.sdrplayApi = {
    enable = lib.mkOption {
      default = false;

      description = ''
        Whether to enable the SDRplay API service and udev rules.

        ::: {.note}
        To enable integration with SoapySDR and GUI applications like gqrx create an overlay containing
        `soapysdr-with-plugins = super.soapysdr.override { extraPackages = [ super.soapysdrplay ]; };`
        :::
      '';

      example = true;
      type = lib.types.bool;
    };
  };

  config = lib.mkIf config.services.sdrplayApi.enable {
    services.udev.packages = [ pkgs.sdrplay ];

    systemd.services.sdrplayApi = {
      after = [ "network.target" ];
      description = "SDRplay API Service";

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${pkgs.sdrplay}/bin/sdrplay_apiService";
        Restart = "on-failure";
        RestartSec = "1s";
      };

      wantedBy = [ "multi-user.target" ];
    };

  };
}
