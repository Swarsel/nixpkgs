# Non-module dependencies (`importApply`)
{ }:

# Service module
{
  lib,
  config,
  options,
  ...
}:
let
  inherit (lib)
    concatMap
    getExe
    mkOption
    optional
    types
    ;
  cfg = config.snid;
in
{
  # https://nixos.org/manual/nixos/unstable/#modular-services
  _class = "service";

  config = {
    assertions = [
      {
        assertion = cfg.mode == "nat46" -> cfg.nat46Prefix != null;
        message = "snid: `nat46Prefix` must be set when `mode` is `nat46`.";
      }
      {
        assertion = cfg.mode == "nat46" -> cfg.backendCidrs != [ ];
        message = "snid: `backendCidrs` must be set when `mode` is `nat46`.";
      }
      {
        assertion = cfg.mode == "tcp" -> cfg.backendCidrs != [ ];
        message = "snid: `backendCidrs` must be set when `mode` is `tcp`.";
      }
      {
        assertion = cfg.mode == "unix" -> cfg.unixDirectory != null;
        message = "snid: `unixDirectory` must be set when `mode` is `unix`.";
      }
    ];

    process.argv = [
      (getExe cfg.package)
      "-mode"
      cfg.mode
    ]
    ++ concatMap (l: [
      "-listen"
      l
    ]) cfg.listen
    ++ concatMap (c: [
      "-backend-cidr"
      c
    ]) cfg.backendCidrs
    ++ optional (cfg.defaultHostname != null) "-default-hostname=${cfg.defaultHostname}"
    ++ optional (cfg.nat46Prefix != null) "-nat46-prefix=${cfg.nat46Prefix}"
    ++ optional (cfg.backendPort != null) "-backend-port=${toString cfg.backendPort}"
    ++ optional (cfg.unixDirectory != null) "-unix-directory=${cfg.unixDirectory}"
    ++ optional cfg.proxyProto "-proxy-proto";
  }
  // lib.optionalAttrs (options ? systemd) {
    systemd.service = {
      after = [ "network.target" ];

      serviceConfig = {
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        DynamicUser = true;
        Restart = "on-failure";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network.target" ];
    };
  };

  options = {
    snid = {
      backendCidrs = mkOption {
        default = [ ];

        description = ''
          Subnets to which connections may be forwarded. Connections to
          addresses outside these subnets are rejected. Used in `nat46` and
          `tcp` modes.
        '';

        example = [
          "2001:db8::/64"
          "192.0.2.0/24"
        ];

        type = types.listOf types.str;
      };

      backendPort = mkOption {
        default = null;

        description = ''
          Port number to connect to on the backend in TCP mode. If null,
          snid uses the same port as the inbound connection.
        '';

        type = types.nullOr types.port;
      };

      defaultHostname = mkOption {
        default = null;

        description = ''
          Hostname to use if a client does not include the SNI extension.
          If null, SNI-less connections will be terminated with a TLS alert.
        '';

        type = types.nullOr types.str;
      };

      listen = mkOption {
        description = ''
          Addresses to listen on, in go-listener syntax.

          Examples: `"tcp:443"`, `"tcp:0.0.0.0:443"`, `"tcp:192.0.2.4:443"`.
        '';

        example = [ "tcp:0.0.0.0:443" ];
        type = types.listOf types.str;
      };

      mode = mkOption {
        description = ''
          Proxy mode. One of `nat46`, `tcp`, or `unix`.
        '';

        type = types.enum [
          "nat46"
          "tcp"
          "unix"
        ];
      };

      nat46Prefix = mkOption {
        default = null;

        description = ''
          IPv6 prefix for the source address when connecting to the backend
          in NAT46 mode. The client's IPv4 address is placed in the lower 4
          bytes.

          Note: this prefix must be routed to the local host, e.g.
          ```
          ip route add local 64:ff9b:1::/96 dev lo
          ```
        '';

        example = "64:ff9b:1::";
        type = types.nullOr types.str;
      };

      package = mkOption {
        defaultText = "The snid package that provided this module.";
        description = "Package to use for snid.";
        type = types.package;
      };

      proxyProto = mkOption {
        default = false;

        description = ''
          Use PROXY protocol v2 to convey the client IP address to the
          backend. Applicable in `tcp` and `unix` modes.
        '';

        type = types.bool;
      };

      unixDirectory = mkOption {
        default = null;

        description = ''
          Path to the directory containing UNIX domain sockets, used in
          `unix` mode.
        '';

        type = types.nullOr types.path;
      };
    };
  };
}
