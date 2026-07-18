{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    types
    mkOption
    hasPrefix
    concatMapStringsSep
    optionalString
    concatMap
    ;
  inherit (builtins) isNull;

  cfg = config.services.varnish;

  # Varnish has very strong opinions and very complicated code around handling
  # the stateDir. After a lot of back and forth, we decided that we a)
  # do not want a configurable option here, as most of the handling depends
  # on the compile time options. Putting everything into /var/run (RAM backed)
  # is absolutely recommended by Varnish anyways.
  stateDir = "/var/run/varnishd";

  # from --help:
  #   -a [<name>=]address[:port][,proto] # HTTP listen address and port
  #      [,user=<u>][,group=<g>]   # Can be specified multiple times.
  #      [,mode=<m>]               #   default: ":80,HTTP"
  #                                # Proto can be "PROXY" or "HTTP" (default)
  #                                # user, group and mode set permissions for
  #                                #   a Unix domain socket.
  commandLineAddresses =
    (concatMapStringsSep " " (
      a:
      "-a "
      + optionalString (!isNull a.name) "${a.name}="
      + a.address
      + optionalString (!isNull a.port) ":${toString a.port}"
      + optionalString (!isNull a.proto) ",${a.proto}"
      + optionalString (!isNull a.user) ",user=${a.user}"
      + optionalString (!isNull a.group) ",group=${a.group}"
      + optionalString (!isNull a.mode) ",mode=${a.mode}"
    ) cfg.listen)
    + lib.optionalString (!isNull cfg.http_address) " -a ${cfg.http_address}";
  addressSubmodule = types.submodule {
    options = {
      address = mkOption {
        description = ''
          If given an IP address, it can be a host name ("localhost"), an IPv4 dotted-quad
          ("127.0.0.1") or an IPv6  address enclosed in square brackets ("[::1]").

          (VCL4.1 and higher) If given an absolute Path ("/path/to/listen.sock") or "@"
          followed by the name of an abstract socket ("@myvarnishd") accept connections
          on a Unix domain socket.

          The user, group and mode sub-arguments may be used to specify the permissions
          of the socket file. These sub-arguments do not apply to  abstract sockets.
        '';

        type = types.str;
      };

      group = mkOption {
        default = null;
        description = "Group name who owns the socket file.";
        type = with lib.types; nullOr str;
      };

      mode = mkOption {
        default = null;
        description = "Permission of the socket file (3-digit octal value).";
        type = with types; nullOr str;
      };

      name = mkOption {
        default = null;
        description = "Name is referenced in logs. If name is not specified, 'a0', 'a1', etc. is used.";
        type = with types; nullOr str;
      };

      port = mkOption {
        default = null;
        description = "The port to use for IP sockets. If port is not specified, port 80 (http) is used.";
        type = with types; nullOr port;
      };

      proto = mkOption {
        default = "HTTP";
        description = "PROTO can be 'HTTP' (the default) or 'PROXY'.  Both version 1 and 2 of the proxy protocol can be used.";

        type = types.enum [
          "HTTP"
          "PROXY"
        ];
      };

      user = mkOption {
        default = null;
        description = "User name who owns the socket file.";
        type = with lib.types; nullOr str;
      };
    };
  };
  checkedAddressModule = types.addCheck addressSubmodule (
    m:
    (
      if ((hasPrefix "@" m.address) || (hasPrefix "/" m.address)) then
        # this is a unix socket
        (m.port != null)
      else
      # this is not a path-based unix socket
      if !(hasPrefix "/" m.address) && (m.group != null) || (m.user != null) || (m.mode != null) then
        false
      else
        true
    )
  );
  commandLine =
    "-f ${pkgs.writeText "default.vcl" cfg.config}"
    +
      lib.optionalString (cfg.extraModules != [ ])
        " -p vmod_path='${
           lib.makeSearchPathOutput "lib" "lib/varnish/vmods" ([ cfg.package ] ++ cfg.extraModules)
         }' -r vmod_path";
in
{
  imports = [
    (lib.mkRemovedOptionModule [
      "services"
      "varnish"
      "stateDir"
    ] "The `stateDir` option never was functional or useful. varnish uses compile-time settings.")
  ];

  options = {
    services.varnish = {
      config = lib.mkOption {
        description = ''
          Verbatim default.vcl configuration.
        '';

        type = lib.types.lines;
      };

      enable = lib.mkEnableOption "Varnish Server";
      package = lib.mkPackageOption pkgs "varnish" { };

      enableConfigCheck = lib.mkEnableOption "checking the config during build time" // {
        default = true;
      };

      extraCommandLine = lib.mkOption {
        default = "";

        description = ''
          Command line switches for varnishd (run 'varnishd -?' to get list of options)
        '';

        example = "-s malloc,256M";
        type = lib.types.str;
      };

      extraModules = lib.mkOption {
        default = [ ];

        description = ''
          Varnish modules (except 'std').
        '';

        example = lib.literalExpression "[ pkgs.varnishPackages.geoip ]";
        type = lib.types.listOf lib.types.package;
      };

      http_address = lib.mkOption {
        default = null;

        description = ''
          HTTP listen address and port.
        '';

        type = with lib.types; nullOr str;
      };

      listen = lib.mkOption {
        default = lib.optional (isNull cfg.http_address) {
          address = "*";
          port = 6081;
        };

        defaultText = lib.literalExpression ''[ { address="*"; port=6081; } ]'';
        description = "Accept for client requests on the specified listen addresses.";
        type = lib.types.listOf checkedAddressModule;
      };
    };

  };

  config = lib.mkIf cfg.enable {
    assertions =
      (concatMap (m: [
        {
          assertion = (hasPrefix "/" m.address) || (hasPrefix "@" m.address) -> m.port == null;
          message = "Listen ports must not be specified with UNIX sockets: ${builtins.toJSON m}";
        }
        {
          assertion = !(hasPrefix "/" m.address) -> m.user == null && m.group == null && m.mode == null;
          message = "Abstract UNIX sockets or IP sockets can not be used with user, group, and mode settings: ${builtins.toJSON m}";
        }
      ]) cfg.listen)
      ++ [
        {
          assertion = cfg.package.pname != "vinyl-cache";
          message = "services.varnish only supports Varnish Cache. Please use services.vinyl-cache.";
        }
      ];

    environment.systemPackages = [ cfg.package ];

    # check .vcl syntax at compile time (e.g. before nixops deployment)
    system.checks = lib.mkIf cfg.enableConfigCheck [
      (pkgs.runCommand "check-varnish-syntax" { } ''
        ${cfg.package}/bin/varnishd -C ${commandLine} 2> $out || (cat $out; exit 1)
      '')
    ];

    systemd.services.varnish = {
      after = [ "network.target" ];
      description = "Varnish";

      serviceConfig = {
        AmbientCapabilities = "cap_net_bind_service";
        ExecStart = "${cfg.package}/sbin/varnishd ${commandLineAddresses} -n ${stateDir} -F ${cfg.extraCommandLine} ${commandLine}";
        Group = "varnish";
        LimitNOFILE = 131072;
        NoNewPrivileges = true;
        PermissionsStartOnly = true;
        Restart = "always";
        RestartSec = "5s";
        RuntimeDirectory = lib.removePrefix "/var/run/" stateDir;
        Type = "simple";
        User = "varnish";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.varnish.gid = config.ids.uids.varnish;

    users.users.varnish = {
      group = "varnish";
      uid = config.ids.uids.varnish;
    };

    warnings =
      lib.optional (!isNull cfg.http_address)
        "The option `services.varnish.http_address` is deprecated. Use `services.varnish.listen` instead.";
  };
}
