{
  config,
  lib,
  pkgs,
  options,
  ...
}:

with lib;

let
  cfg = config.services.openntpd;

  package = pkgs.openntpd_nixos;

  configFile = ''
    ${concatStringsSep "\n" (map (s: "server ${s}") cfg.servers)}
    ${cfg.extraConfig}
  '';

  pidFile = "/run/openntpd.pid";

in
{
  ###### interface
  options.services.openntpd = {
    enable = mkEnableOption "OpenNTP time synchronization server";

    extraConfig = mkOption {
      default = "";

      description = ''
        Additional text appended to {file}`openntpd.conf`.
      '';

      example = ''
        listen on 127.0.0.1
        listen on ::1
      '';

      type = with types; lines;
    };

    extraOptions = mkOption {
      default = "";

      description = ''
        Extra options used when launching openntpd.
      '';

      example = "-s";
      type = with types; separatedString " ";
    };

    servers = mkOption {
      inherit (options.services.ntp.servers) description;
      default = config.services.ntp.servers;
      defaultText = literalExpression "config.services.ntp.servers";
      type = types.listOf types.str;
    };
  };

  config = mkIf cfg.enable {
    environment.etc."ntpd.conf".text = configFile;
    # Add ntpctl to the environment for status checking
    environment.systemPackages = [ package ];
    services.timesyncd.enable = mkForce false;

    systemd.services.openntpd = {
      after = [
        "dnsmasq.service"
        "bind.service"
        "network-online.target"
      ];

      before = [ "time-sync.target" ];
      description = "OpenNTP Server";

      serviceConfig = {
        ExecStart = "${package}/sbin/ntpd -p ${pidFile} ${cfg.extraOptions}";
        PIDFile = pidFile;
        Type = "forking";
      };

      wantedBy = [ "multi-user.target" ];

      wants = [
        "network-online.target"
        "time-sync.target"
      ];
    };

    users.groups.ntp = { };

    users.users.ntp = {
      description = "OpenNTP daemon user";
      group = "ntp";
      home = "/var/empty";
      isSystemUser = true;
    };
  };

  ###### implementation
  meta.maintainers = with lib.maintainers; [ thoughtpolice ];
}
