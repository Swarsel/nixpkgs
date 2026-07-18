{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.v2raya;
in

{
  options = {
    services.v2raya = {
      enable = options.mkEnableOption "the v2rayA service";
      package = options.mkPackageOption pkgs "v2raya" { };

      cliPackage = options.mkPackageOption pkgs "v2ray" {
        example = "pkgs.xray";
        extraDescription = "This is the package used for overriding the value of the `v2ray` attribute in the package set by `services.v2raya.package`.";
      };
    };
  };

  config = mkIf config.services.v2raya.enable {
    environment.systemPackages = [ (cfg.package.override { v2ray = cfg.cliPackage; }) ];

    systemd.services.v2raya =
      let
        nftablesEnabled = config.networking.nftables.enable;
        iptablesServices = [
          "iptables.service"
        ]
        ++ optional config.networking.enableIPv6 "ip6tables.service";
        tableServices = if nftablesEnabled then [ "nftables.service" ] else iptablesServices;
      in
      {
        path =
          with pkgs;
          [
            iptables
            bash
            iproute2
          ]
          ++ lib.optionals nftablesEnabled [ nftables ]; # required by v2rayA TProxy functionality

        serviceConfig = {
          Environment = [ "V2RAYA_LOG_FILE=/var/log/v2raya/v2raya.log" ];
          ExecStart = "${getExe (cfg.package.override { v2ray = cfg.cliPackage; })} --log-disable-timestamp";
          LimitNOFILE = 1000000;
          LimitNPROC = 500;
          Restart = "on-failure";
          Type = "simple";
          User = "root";
        };

        unitConfig = {
          After = [
            "network.target"
            "nss-lookup.target"
          ]
          ++ tableServices;

          Description = "v2rayA service";
          Documentation = "https://github.com/v2rayA/v2rayA/wiki";
          Wants = [ "network.target" ];
        };

        wantedBy = [ "multi-user.target" ];
      };
  };

  meta.maintainers = with maintainers; [ elliot ];
}
