{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let

  cfg = config.services.postgrey;

  socket =
    with types;
    addCheck (either (submodule unixSocket) (submodule inetSocket)) (x: x ? path || x ? port);

  inetSocket = with types; {
    options = {
      addr = mkOption {
        default = null;
        description = "The address to bind to. Localhost if null";
        example = "127.0.0.1";
        type = nullOr str;
      };

      port = mkOption {
        default = 10030;
        description = "Tcp port to bind to";
        type = port;
      };
    };
  };

  unixSocket = with types; {
    options = {
      mode = mkOption {
        default = "0777";
        description = "Mode of the unix socket";
        type = str;
      };

      path = mkOption {
        default = "/run/postgrey.sock";
        description = "Path of the unix socket";
        type = path;
      };
    };
  };

in
{
  imports = [
    (mkMergedOptionModule
      [
        [
          "services"
          "postgrey"
          "inetAddr"
        ]
        [
          "services"
          "postgrey"
          "inetPort"
        ]
      ]
      [ "services" "postgrey" "socket" ]
      (
        config:
        let
          value = p: getAttrFromPath p config;
          inetAddr = [
            "services"
            "postgrey"
            "inetAddr"
          ];
          inetPort = [
            "services"
            "postgrey"
            "inetPort"
          ];
        in
        if value inetAddr == null then
          { path = "/run/postgrey.sock"; }
        else
          {
            addr = value inetAddr;
            port = value inetPort;
          }
      )
    )
  ];

  options = {
    services.postgrey = with types; {
      enable = mkOption {
        default = false;
        description = "Whether to run the Postgrey daemon";
        type = bool;
      };

      IPv4CIDR = mkOption {
        default = 24;
        description = "Strip N bits from IPv4 addresses if lookupBySubnet is true";
        type = ints.unsigned;
      };

      IPv6CIDR = mkOption {
        default = 64;
        description = "Strip N bits from IPv6 addresses if lookupBySubnet is true";
        type = ints.unsigned;
      };

      autoWhitelist = mkOption {
        default = 5;
        description = "Whitelist clients after successful delivery of N messages";
        type = nullOr ints.positive;
      };

      delay = mkOption {
        default = 300;
        description = "Greylist for N seconds";
        type = ints.unsigned;
      };

      greylistAction = mkOption {
        default = "DEFER_IF_PERMIT";
        description = "Response status for greylisted messages (see {manpage}`access(5)`)";
        type = str;
      };

      greylistHeader = mkOption {
        default = "X-Greylist: delayed %%t seconds by postgrey-%%v at %%h; %%d";
        description = "Prepend header to greylisted mails; use %%t for seconds delayed due to greylisting, %%v for the version of postgrey, %%d for the date, and %%h for the host";
        type = str;
      };

      greylistText = mkOption {
        default = "Greylisted for %%s seconds";
        description = "Response status text for greylisted messages; use %%s for seconds left until greylisting is over and %%r for mail domain of recipient";
        type = str;
      };

      lookupBySubnet = mkOption {
        default = true;
        description = "Strip the last N bits from IP addresses, determined by IPv4CIDR and IPv6CIDR";
        type = bool;
      };

      maxAge = mkOption {
        default = 35;
        description = "Delete entries from whitelist if they haven't been seen for N days";
        type = ints.unsigned;
      };

      privacy = mkOption {
        default = true;
        description = "Store data using one-way hash functions (SHA1)";
        type = bool;
      };

      retryWindow = mkOption {
        default = 2;
        description = "Allow N days for the first retry. Use string with appended 'h' to specify time in hours";
        example = "12h";
        type = either str ints.unsigned;
      };

      socket = mkOption {
        default = {
          mode = "0777";
          path = "/run/postgrey.sock";
        };

        description = "Socket to bind to";

        example = {
          addr = "127.0.0.1";
          port = 10030;
        };

        type = socket;
      };

      whitelistClients = mkOption {
        default = [ ];
        description = "Client address whitelist files (see {manpage}`postgrey(8)`)";
        type = listOf path;
      };

      whitelistRecipients = mkOption {
        default = [ ];
        description = "Recipient address whitelist files (see {manpage}`postgrey(8)`)";
        type = listOf path;
      };
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkgs.postgrey ];

    systemd.services.postgrey =
      let
        bind-flag =
          if cfg.socket ? path then
            "--unix=${cfg.socket.path} --socketmode=${cfg.socket.mode}"
          else
            "--inet=${
              optionalString (cfg.socket.addr != null) (cfg.socket.addr + ":")
            }${toString cfg.socket.port}";
      in
      {
        before = [ "postfix.service" ];
        description = "Postfix Greylisting Service";

        serviceConfig = {
          ExecStart = ''
            ${pkgs.postgrey}/bin/postgrey \
                      ${bind-flag} \
                      --group=postgrey --user=postgrey \
                      --dbdir=/var/postgrey \
                      --delay=${toString cfg.delay} \
                      --max-age=${toString cfg.maxAge} \
                      --retry-window=${toString cfg.retryWindow} \
                      ${if cfg.lookupBySubnet then "--lookup-by-subnet" else "--lookup-by-host"} \
                      --ipv4cidr=${toString cfg.IPv4CIDR} --ipv6cidr=${toString cfg.IPv6CIDR} \
                      ${optionalString cfg.privacy "--privacy"} \
                      --auto-whitelist-clients=${
                        toString (if cfg.autoWhitelist == null then 0 else cfg.autoWhitelist)
                      } \
                      --greylist-action=${cfg.greylistAction} \
                      --greylist-text="${cfg.greylistText}" \
                      --x-greylist-header="${cfg.greylistHeader}" \
                      ${concatMapStringsSep " " (x: "--whitelist-clients=" + x) cfg.whitelistClients} \
                      ${concatMapStringsSep " " (x: "--whitelist-recipients=" + x) cfg.whitelistRecipients}
          '';

          ExecStartPre = [
            "${lib.getExe' pkgs.coreutils "mkdir"} -p /var/postgrey"
            "${lib.getExe' pkgs.coreutils "chown"} postgrey:postgrey /var/postgrey"
            "${lib.getExe' pkgs.coreutils "chmod"} 0770 /var/postgrey"
          ];

          Restart = "always";
          RestartSec = 5;
          TimeoutSec = 10;
          Type = "simple";
        };

        wantedBy = [ "multi-user.target" ];
      };

    users = {
      groups = {
        postgrey = {
          gid = config.ids.gids.postgrey;
        };
      };

      users = {
        postgrey = {
          description = "Postgrey Daemon";
          group = "postgrey";
          uid = config.ids.uids.postgrey;
        };
      };
    };

  };

}
