{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.logmein-hamachi;

in

{

  ###### interface

  options = {

    services.logmein-hamachi.enable = lib.mkOption {
      default = false;

      description = ''
        Whether to enable LogMeIn Hamachi, a proprietary
        (closed source) commercial VPN software.
      '';

      type = lib.types.bool;
    };

  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ pkgs.logmein-hamachi ];

    systemd.services.logmein-hamachi = {
      after = [ "network.target" ];
      description = "LogMeIn Hamachi Daemon";

      serviceConfig = {
        ExecStart = "${pkgs.logmein-hamachi}/bin/hamachid";
        Type = "forking";
      };

      wantedBy = [ "multi-user.target" ];
    };

  };

}
