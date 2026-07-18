{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.saslauthd;

in

{

  ###### interface

  options = {

    services.saslauthd = {

      config = lib.mkOption {
        default = "";
        description = "Configuration to use for Cyrus SASL authentication daemon.";
        type = lib.types.lines;
      };

      enable = lib.mkEnableOption "saslauthd, the Cyrus SASL authentication daemon";
      package = lib.mkPackageOption pkgs [ "cyrus_sasl" "bin" ] { };

      mechanism = lib.mkOption {
        default = "pam";
        description = "Auth mechanism to use";
        type = lib.types.str;
      };

    };

  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    systemd.services.saslauthd = {
      description = "Cyrus SASL authentication daemon";

      serviceConfig = {
        ExecStart = "@${cfg.package}/sbin/saslauthd saslauthd -a ${cfg.mechanism} -O ${pkgs.writeText "saslauthd.conf" cfg.config}";
        PIDFile = "/run/saslauthd/saslauthd.pid";
        Restart = "always";
        Type = "forking";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
