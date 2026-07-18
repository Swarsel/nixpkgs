{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.tor.torsocks;
  optionalNullStr = b: v: lib.optionalString (b != null) v;

  configFile = server: ''
    TorAddress ${toString (lib.head (lib.splitString ":" server))}
    TorPort    ${toString (lib.tail (lib.splitString ":" server))}

    OnionAddrRange ${cfg.onionAddrRange}

    ${optionalNullStr cfg.socks5Username "SOCKS5Username ${cfg.socks5Username}"}
    ${optionalNullStr cfg.socks5Password "SOCKS5Password ${cfg.socks5Password}"}

    AllowInbound ${if cfg.allowInbound then "1" else "0"}
  '';

  wrapTorsocks =
    name: server:
    pkgs.writeTextFile {
      destination = "/bin/${name}";
      executable = true;
      name = name;

      text = ''
        #!${pkgs.runtimeShell}
        TORSOCKS_CONF_FILE=${pkgs.writeText "torsocks.conf" (configFile server)} ${pkgs.torsocks}/bin/torsocks "$@"
      '';
    };

in
{
  options = {
    services.tor.torsocks = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to build `/etc/tor/torsocks.conf`
          containing the specified global torsocks configuration.
        '';

        type = lib.types.bool;
      };

      allowInbound = lib.mkOption {
        default = false;

        description = ''
          Set Torsocks to accept inbound connections. If set to
          `true`, listen() and accept() will be
          allowed to be used with non localhost address.
        '';

        type = lib.types.bool;
      };

      fasterServer = lib.mkOption {
        default = "127.0.0.1:9063";

        description = ''
          IP/Port of the Tor SOCKS server for torsocks-faster wrapper suitable for HTTP.
          Currently, hostnames are NOT supported by torsocks.
        '';

        example = "192.168.0.20:1234";
        type = lib.types.str;
      };

      onionAddrRange = lib.mkOption {
        default = "127.42.42.0/24";

        description = ''
          Tor hidden sites do not have real IP addresses. This
          specifies what range of IP addresses will be handed to the
          application as "cookies" for .onion names.  Of course, you
          should pick a block of addresses which you aren't going to
          ever need to actually connect to. This is similar to the
          MapAddress feature of the main tor daemon.
        '';

        type = lib.types.str;
      };

      server = lib.mkOption {
        default = "127.0.0.1:9050";

        description = ''
          IP/Port of the Tor SOCKS server. Currently, hostnames are
          NOT supported by torsocks.
        '';

        example = "192.168.0.20:1234";
        type = lib.types.str;
      };

      socks5Password = lib.mkOption {
        default = null;

        description = ''
          SOCKS5 password. The `TORSOCKS_PASSWORD`
          environment variable overrides this option if it is set.
        '';

        example = "sekret";
        type = lib.types.nullOr lib.types.str;
      };

      socks5Username = lib.mkOption {
        default = null;

        description = ''
          SOCKS5 username. The `TORSOCKS_USERNAME`
          environment variable overrides this option if it is set.
        '';

        example = "bob";
        type = lib.types.nullOr lib.types.str;
      };

    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."tor/torsocks.conf" = {
      source = pkgs.writeText "torsocks.conf" (configFile cfg.server);
    };

    environment.systemPackages = [
      pkgs.torsocks
      (wrapTorsocks "torsocks-faster" cfg.fasterServer)
    ];
  };
}
