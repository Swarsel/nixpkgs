{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.services.ircdHybrid;

  ircdService = pkgs.stdenv.mkDerivation rec {
    inherit (pkgs)
      ircd-hybrid
      coreutils
      su
      iproute2
      gnugrep
      procps
      ;

    inherit (cfg)
      serverName
      sid
      description
      adminEmail
      extraPort
      ;

    builder = ./builder.sh;

    cryptoSettings =
      (optionalString (cfg.rsaKey != null) "rsa_private_key_file = \"${cfg.rsaKey}\";\n")
      + (optionalString (cfg.certificate != null) "ssl_certificate_file = \"${cfg.certificate}\";\n");

    extraListen = map (
      ip: "host = \"" + ip + "\";\nport = 6665 .. 6669, " + extraPort + "; "
    ) cfg.extraIPs;

    ipv6Enabled = boolToString config.networking.enableIPv6;
    name = "ircd-hybrid-service";

    scripts = [
      "=>/bin"
      ./control.in
    ];

    substFiles = [
      "=>/conf"
      ./ircd.conf
    ];
  };

in

{

  ###### interface

  options = {

    services.ircdHybrid = {

      enable = mkEnableOption "IRCD";

      adminEmail = mkOption {
        default = "<bit-bucket@example.com>";

        description = ''
          IRCD server administrator e-mail.
        '';

        example = "<name@domain.tld>";
        type = types.str;
      };

      certificate = mkOption {
        default = null;

        description = ''
          IRCD server SSL certificate. There are some limitations - read manual.
        '';

        example = literalExpression "/root/certificates/irc.pem";
        type = types.nullOr types.path;
      };

      description = mkOption {
        default = "Hybrid-7 IRC server.";

        description = ''
          IRCD server description.
        '';

        type = types.str;
      };

      extraIPs = mkOption {
        default = [ ];

        description = ''
          Extra IP's to bind.
        '';

        example = [ "127.0.0.1" ];
        type = types.listOf types.str;
      };

      extraPort = mkOption {
        default = "7117";

        description = ''
          Extra port to avoid filtering.
        '';

        type = types.str;
      };

      rsaKey = mkOption {
        default = null;

        description = ''
          IRCD server RSA key.
        '';

        example = literalExpression "/root/certificates/irc.key";
        type = types.nullOr types.path;
      };

      serverName = mkOption {
        default = "hades.arpa";

        description = ''
          IRCD server name.
        '';

        type = types.str;
      };

      sid = mkOption {
        default = "0NL";

        description = ''
          IRCD server unique ID in a net of servers.
        '';

        type = types.str;
      };

    };

  };

  ###### implementation

  config = mkIf config.services.ircdHybrid.enable {

    systemd.services.ircd-hybrid = {
      after = [ "network-online.target" ];
      description = "IRCD Hybrid server";
      script = "${ircdService}/bin/control start";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

    users.groups.ircd.gid = config.ids.gids.ircd;

    users.users.ircd = {
      description = "IRCD owner";
      group = "ircd";
      uid = config.ids.uids.ircd;
    };
  };
}
