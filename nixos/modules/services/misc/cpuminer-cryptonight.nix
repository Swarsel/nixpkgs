{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.cpuminer-cryptonight;

  json = builtins.toJSON (
    cfg
    // {
      enable = null;
      threads = if cfg.threads == 0 then null else toString cfg.threads;
    }
  );

  confFile = builtins.toFile "cpuminer.json" json;
in
{

  options = {

    services.cpuminer-cryptonight = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable the cpuminer cryptonight miner.
        '';

        type = lib.types.bool;
      };

      pass = lib.mkOption {
        default = "x";
        description = "Password for mining server";
        type = lib.types.str;
      };

      threads = lib.mkOption {
        default = 0;
        description = "Number of miner threads, defaults to available processors";
        type = lib.types.ints.unsigned;
      };

      url = lib.mkOption {
        description = "URL of mining server";
        type = lib.types.str;
      };

      user = lib.mkOption {
        description = "Username for mining server";
        type = lib.types.str;
      };
    };

  };

  config = lib.mkIf config.services.cpuminer-cryptonight.enable {

    systemd.services.cpuminer-cryptonight = {
      after = [ "network.target" ];
      description = "Cryptonight cpuminer";

      serviceConfig = {
        ExecStart = "${pkgs.cpuminer-multi}/bin/minerd --syslog --config=${confFile}";
        User = "nobody";
      };

      wantedBy = [ "multi-user.target" ];
    };

  };

}
