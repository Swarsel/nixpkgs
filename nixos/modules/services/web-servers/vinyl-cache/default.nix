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

  cfg = config.services.vinyl-cache;

  # Vinyl Cache has very strong opinions and very complicated code around handling
  # the stateDir. After a lot of back and forth, we decided to set the stateDir
  # at compile time and let the package expose the particular path as passthru.
  stateDir = cfg.package.stateDir;

  # from --help:
  #   -a [<name>=]address[:port][,proto] # HTTP listen address and port
  #      [,user=<u>][,group=<g>]   # Can be specified multiple times.
  #      [,mode=<m>]               #   default: ":80,HTTP"
  #                                # Proto can be "PROXY" or "HTTP" (default)
  #                                # user, group and mode set permissions for
  #                                #   a Unix domain socket.
  commandLineAddresses = (
    concatMapStringsSep " " (
      a:
      "-a "
      + optionalString (!isNull a.name) "${a.name}="
      + a.address
      + optionalString (!isNull a.port) ":${toString a.port}"
      + optionalString (!isNull a.proto) ",${a.proto}"
      + optionalString (!isNull a.user) ",user=${a.user}"
      + optionalString (!isNull a.group) ",group=${a.group}"
      + optionalString (!isNull a.mode) ",mode=${a.mode}"
    ) cfg.listen
  );

  addressSubmodule = types.submodule {
    options = {
      address = mkOption {
        description = ''
          If given an IP address, it can be a host name ("localhost"), an IPv4 dotted-quad
          ("127.0.0.1") or an IPv6  address enclosed in square brackets ("[::1]").

          (VCL4.1 and higher) If given an absolute Path ("/path/to/listen.sock") or "@"
          followed by the name of an abstract socket ("@myvinyld") accept connections
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
           lib.makeSearchPathOutput "lib" "lib/vinyl/vmods" ([ cfg.package ] ++ cfg.extraModules)
         }' -r vmod_path";
in
{
  options = {
    services.vinyl-cache = {
      config = lib.mkOption {
        description = ''
          Verbatim default.vcl configuration.
        '';

        type = lib.types.lines;
      };

      enable = lib.mkEnableOption "Vinyl Cache";
      package = lib.mkPackageOption pkgs "vinyl-cache" { };

      enableConfigCheck = lib.mkEnableOption "checking the config during build time" // {
        default = true;
      };

      enableFileLogging = lib.mkEnableOption "file based logging";

      extraCommandLine = lib.mkOption {
        default = "";

        description = ''
          Command line switches for vinyld (run 'vinyld -?' to get list of options)
        '';

        example = "-s malloc,256M";
        type = lib.types.str;
      };

      extraModules = lib.mkOption {
        default = [ ];

        description = ''
          Vinyl Cache modules (except 'std').
        '';

        type = lib.types.listOf lib.types.package;
      };

      listen = lib.mkOption {
        default = [
          {
            address = "*";
            port = 6081;
          }
        ];

        defaultText = lib.literalExpression ''[ { address="*"; port=6081; } ]'';
        description = "Accept for client requests on the specified listen addresses.";
        type = lib.types.listOf checkedAddressModule;
      };
    };

  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      assertions =
        concatMap (m: [
          {
            assertion = (hasPrefix "/" m.address) || (hasPrefix "@" m.address) -> m.port == null;
            message = "Listen ports must not be specified with UNIX sockets: ${builtins.toJSON m}";
          }
          {
            assertion = !(hasPrefix "/" m.address) -> m.user == null && m.group == null && m.mode == null;
            message = "Abstract UNIX sockets or IP sockets can not be used with user, group, and mode settings: ${builtins.toJSON m}";
          }
        ]) cfg.listen
        ++ [
          {
            assertion = cfg.package.pname == "vinyl-cache";
            message = "services.vinyl-cache only supports Vinyl Cache. Please use services.varnish.";
          }
          {
            assertion = lib.strings.hasPrefix "/run/" stateDir;
            message = "The vinyl-cache NixOS mosule only supports statedirs in /run/, but vinyl-cache package was compiled with ${stateDir}.";
          }
        ];

      environment.systemPackages = [ cfg.package ];

      # check .vcl syntax at compile time (e.g. before nixops deployment)
      system.checks = lib.mkIf cfg.enableConfigCheck [
        (pkgs.runCommand "check-vinyl-cache-syntax" { } ''
          ${cfg.package}/bin/vinyld -C ${commandLine} 2> $out || (cat $out; exit 1)
        '')
      ];

      systemd.services.vinyl-cache = {
        after = [ "network.target" ];
        description = "Vinyl Cache";

        serviceConfig = {
          AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
          DynamicUser = true;
          ExecStart = "${cfg.package}/bin/vinyld ${commandLineAddresses} -F ${cfg.extraCommandLine} ${commandLine}";
          Group = "vinyl-cache";
          LimitNOFILE = 131072;
          NoNewPrivileges = true;
          Restart = "always";
          RestartSec = "5s";
          RuntimeDirectory = lib.removePrefix "/run/" stateDir;
          Type = "simple";
          User = "vinyl-cache";
        };

        wantedBy = [ "multi-user.target" ];
      };
    })
    (lib.mkIf (cfg.enable && cfg.enableFileLogging) {
      services.logrotate.settings.vinyl-cache = lib.mapAttrs (_: lib.mkDefault) {
        compress = true;
        delaycompress = true;
        files = [ "/var/log/vinyl-cache/*.log" ];
        frequency = "daily";
        postrotate = "systemctl reload vinylncsa";
        rotate = 14;
      };

      systemd.services = {
        vinylncsa = {
          after = [ "vinyl-cache.service" ];
          description = "Vinyl Cache logging daemon";
          requires = [ "vinyl-cache.service" ];

          # We want to reopen logs with HUP. vinylncsa must run in daemon mode for that.
          serviceConfig = {
            ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
            ExecStart = "${cfg.package}/bin/vinylncsa -D -a -w /var/log/vinyl-cache/vinyl-cache.log -P /run/vinylncsa/vinylncsa.pid";
            Group = "vinyl-cache";
            LogsDirectory = "vinyl-cache";
            PIDFile = "/run/vinylncsa/vinylncsa.pid";
            Restart = "always";
            RuntimeDirectory = "vinylncsa";
            Type = "forking";
            User = "vinyl-cache";
          };

          wantedBy = [ "multi-user.target" ];
        };
      };
    })
  ];

  meta.maintainers = [
    lib.maintainers.leona
    lib.maintainers.osnyx
  ];
}
