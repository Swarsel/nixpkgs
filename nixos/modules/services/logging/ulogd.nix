{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.ulogd;
  settingsFormat = pkgs.formats.ini { listsAsDuplicateKeys = true; };
  settingsFile = settingsFormat.generate "ulogd.conf" cfg.settings;
in
{
  options = {
    services.ulogd = {
      enable = lib.mkEnableOption "ulogd, a userspace logging daemon for netfilter/iptables related logging";

      logLevel = lib.mkOption {
        default = 5;
        description = "Log level (1 = debug, 3 = info, 5 = notice, 7 = error, 8 = fatal)";

        type = lib.types.enum [
          1
          3
          5
          7
          8
        ];
      };

      settings = lib.mkOption {
        default = { };
        description = "Configuration for ulogd. See {file}`/share/doc/ulogd/` in `pkgs.ulogd.doc`.";

        example = {
          emu1 = {
            file = "/var/log/ulogd_pkts.log";
            sync = 1;
          };

          global.stack = [
            "log1:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,emu1:LOGEMU"
            "log1:NFLOG,base1:BASE,pcap1:PCAP"
          ];

          log1.group = 2;

          pcap1 = {
            file = "/var/log/ulogd.pcap";
            sync = 1;
          };
        };

        type = settingsFormat.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.ulogd = {
      before = [ "network-pre.target" ];
      description = "Ulogd Daemon";

      serviceConfig = {
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        ExecStart = "${pkgs.ulogd}/bin/ulogd -c ${settingsFile} --verbose --loglevel ${toString cfg.logLevel}";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-pre.target" ];
    };
  };
}
