{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.cgminer;

  convType = v: if lib.isBool v then lib.boolToString v else toString v;
  mergedHwConfig = lib.mapAttrsToList (
    n: v: ''"${n}": "${(lib.concatStringsSep "," (map convType v))}"''
  ) (lib.foldAttrs (n: a: [ n ] ++ a) [ ] cfg.hardware);
  mergedConfig =

    lib.mapAttrsToList (
      n: v: ''"${n}":  ${if lib.isBool v then convType v else ''"${convType v}"''}''
    ) cfg.config;

  cgminerConfig = pkgs.writeText "cgminer.conf" ''
    {
    ${lib.concatStringsSep ",\n" mergedHwConfig},
    ${lib.concatStringsSep ",\n" mergedConfig},
    "pools": [
    ${
      lib.concatStringsSep ",\n" (
        map (v: ''{"url": "${v.url}", "user": "${v.user}", "pass": "${v.pass}"}'') cfg.pools
      )
    }]
    }
  '';
in
{
  ###### interface
  options = {

    services.cgminer = {

      config = lib.mkOption {
        default = { };
        description = "Additional config";

        example = {
          auto-fan = true;
          auto-gpu = true;
          expiry = 120;
          failover-only = true;
          gpu-threads = 2;
          log = 5;
          queue = 1;
          scan-time = 60;
          temp-histeresys = 3;
        };

        type = lib.types.attrsOf (lib.types.either lib.types.bool lib.types.int);
      };

      enable = lib.mkEnableOption "cgminer, an ASIC/FPGA/GPU miner for bitcoin and litecoin";
      package = lib.mkPackageOption pkgs "cgminer" { };

      hardware = lib.mkOption {
        default = [ ]; # Run without options
        description = "List of config options for every GPU";

        example = [
          {
            gpu-engine = "0-985";
            gpu-fan = "0-85";
            gpu-memclock = 860;
            gpu-powertune = 20;
            intensity = 9;
            temp-cutoff = 95;
            temp-overheat = 85;
            temp-target = 75;
          }
          {
            gpu-engine = "0-950";
            gpu-fan = "0-85";
            gpu-memclock = 825;
            gpu-powertune = 20;
            intensity = 9;
            temp-cutoff = 95;
            temp-overheat = 85;
            temp-target = 75;
          }
        ];

        type = lib.types.listOf (lib.types.attrsOf (lib.types.either lib.types.str lib.types.int));
      };

      pools = lib.mkOption {
        default = [ ]; # Run benchmark
        description = "List of pools where to mine";

        example = [
          {
            password = "X";
            url = "http://p2pool.org:9332";
            username = "17EUZxTvs9uRmPsjPZSYUU3zCz9iwstudk";
          }
        ];

        type = lib.types.listOf (lib.types.attrsOf lib.types.str);
      };

      user = lib.mkOption {
        default = "cgminer";
        description = "User account under which cgminer runs";
        type = lib.types.str;
      };
    };
  };

  ###### implementation

  config = lib.mkIf config.services.cgminer.enable {

    environment.systemPackages = [ cfg.package ];

    systemd.services.cgminer = {
      after = [
        "network.target"
        "display-manager.service"
      ];

      environment = {
        DISPLAY = ":${toString config.services.xserver.display}";
        GPU_MAX_ALLOC_PERCENT = "100";
        GPU_USE_SYNC_OBJECTS = "1";
        LD_LIBRARY_PATH = "/run/opengl-driver/lib:/run/opengl-driver-32/lib";
      };

      path = [ pkgs.cgminer ];

      serviceConfig = {
        ExecStart = "${pkgs.cgminer}/bin/cgminer --syslog --text-only --config ${cgminerConfig}";
        Restart = "always";
        RestartSec = "30s";
        User = cfg.user;
      };

      startLimitIntervalSec = 60; # 1 min
      wantedBy = [ "multi-user.target" ];
    };

    users.groups = lib.optionalAttrs (cfg.user == "cgminer") {
      cgminer = { };
    };

    users.users = lib.optionalAttrs (cfg.user == "cgminer") {
      cgminer = {
        description = "Cgminer user";
        group = "cgminer";
        isSystemUser = true;
      };
    };

  };

}
