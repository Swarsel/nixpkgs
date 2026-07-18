{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  configFile = ./xfs.conf;

in

{

  ###### interface

  options = {

    services.xfs = {

      enable = mkOption {
        default = false;
        description = "Whether to enable the X Font Server.";
        type = types.bool;
      };

    };

  };

  ###### implementation

  config = mkIf config.services.xfs.enable {
    assertions = singleton {
      assertion = config.fonts.enableFontDir;
      message = "Please enable fonts.enableFontDir to use the X Font Server.";
    };

    systemd.services.xfs = {
      after = [ "network.target" ];
      description = "X Font Server";
      path = [ pkgs.xfs ];
      script = "xfs -config ${configFile}";
      wantedBy = [ "multi-user.target" ];
    };
  };
}
