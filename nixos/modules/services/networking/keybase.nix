{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.keybase;
in
{

  ###### interface

  options = {

    services.keybase = {

      enable = lib.mkOption {
        default = false;
        description = "Whether to start the Keybase service.";
        type = lib.types.bool;
      };

    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ pkgs.keybase ];

    # Upstream: https://github.com/keybase/client/blob/master/packaging/linux/systemd/keybase.service
    systemd.user.services.keybase = {
      description = "Keybase service";
      environment.KEYBASE_SERVICE_TYPE = "systemd";

      serviceConfig = {
        EnvironmentFile = [
          "-%E/keybase/keybase.autogen.env"
          "-%E/keybase/keybase.env"
        ];

        ExecStart = "${pkgs.keybase}/bin/keybase service";
        PrivateTmp = true;
        Restart = "on-failure";
        Type = "notify";
      };

      unitConfig.ConditionUser = "!@system";
      wantedBy = [ "default.target" ];
    };
  };
}
