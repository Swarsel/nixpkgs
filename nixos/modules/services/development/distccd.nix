{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.distccd;
in
{
  options = {
    services.distccd = {
      enable = lib.mkEnableOption "distccd, a distributed C/C++ compiler";
      package = lib.mkPackageOption pkgs "distcc" { };

      allowedClients = lib.mkOption {
        default = [ "127.0.0.1" ];

        description = ''
          Client IPs which are allowed to connect to distccd in CIDR notation.

          Anyone who can connect to the distccd server can run arbitrary
          commands on that system as the distcc user, therefore you should use
          this judiciously.
        '';

        example = [
          "127.0.0.1"
          "192.168.0.0/24"
          "10.0.0.0/24"
        ];

        type = lib.types.listOf lib.types.str;
      };

      jobTimeout = lib.mkOption {
        default = null;

        description = ''
          Maximum duration, in seconds, of a single compilation request.
        '';

        type = lib.types.nullOr lib.types.int;
      };

      logLevel = lib.mkOption {
        default = "warning";

        description = ''
          Set the minimum severity of error that will be included in the log
          file. Useful if you only want to see error messages rather than an
          entry for each connection.
        '';

        type = lib.types.nullOr (
          lib.types.enum [
            "critical"
            "error"
            "warning"
            "notice"
            "info"
            "debug"
          ]
        );
      };

      maxJobs = lib.mkOption {
        default = null;

        description = ''
          Maximum number of tasks distccd should execute at lib.any time.
        '';

        type = lib.types.nullOr lib.types.int;
      };

      nice = lib.mkOption {
        default = null;

        description = ''
          Niceness of the compilation tasks.
        '';

        type = lib.types.nullOr (lib.types.ints.between (-20) 19);
      };

      openFirewall = lib.mkOption {
        default = false;

        description = ''
          Opens the specified TCP port for distcc.
        '';

        type = lib.types.bool;
      };

      port = lib.mkOption {
        default = 3632;

        description = ''
          The TCP port which distccd will listen on.
        '';

        type = lib.types.port;
      };

      stats = {
        enable = lib.mkEnableOption "statistics reporting via HTTP server";

        port = lib.mkOption {
          default = 3633;

          description = ''
            The TCP port which the distccd statistics HTTP server will listen
            on.
          '';

          type = lib.types.port;
        };
      };

      zeroconf = lib.mkOption {
        default = false;

        description = ''
          Whether to register via mDNS/DNS-SD
        '';

        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ] ++ lib.optionals cfg.stats.enable [ cfg.stats.port ];
    };

    systemd.services.distccd = {
      after = [ "network.target" ];
      description = "Distributed C, C++ and Objective-C compiler";
      documentation = [ "man:distccd(1)" ];

      serviceConfig = {
        # FIXME: I'd love to get rid of `--enable-tcp-insecure` here, but I'm
        # not sure how I'm supposed to get distccd to "accept" running a binary
        # (the compiler) that's outside of /usr/lib.
        ExecStart = pkgs.writeShellScript "start-distccd" ''
          export PATH="${pkgs.distccMasquerade}/bin"
          ${cfg.package}/bin/distccd \
            --no-detach \
            --daemon \
            --enable-tcp-insecure \
            --port ${toString cfg.port} \
            ${lib.optionalString (cfg.jobTimeout != null) "--job-lifetime ${toString cfg.jobTimeout}"} \
            ${lib.optionalString (cfg.logLevel != null) "--log-level ${cfg.logLevel}"} \
            ${lib.optionalString (cfg.maxJobs != null) "--jobs ${toString cfg.maxJobs}"} \
            ${lib.optionalString (cfg.nice != null) "--nice ${toString cfg.nice}"} \
            ${lib.optionalString cfg.stats.enable "--stats"} \
            ${lib.optionalString cfg.stats.enable "--stats-port ${toString cfg.stats.port}"} \
            ${lib.optionalString cfg.zeroconf "--zeroconf"} \
            ${lib.concatMapStrings (c: "--allow ${c} ") cfg.allowedClients}
        '';

        Group = "distcc";
        User = "distcc";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users = {
      groups.distcc.gid = config.ids.gids.distcc;

      users.distcc = {
        description = "distccd user";
        group = "distcc";
        uid = config.ids.uids.distcc;
      };
    };
  };
}
