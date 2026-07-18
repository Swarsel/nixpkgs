{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  inherit (pkgs) ntp;

  cfg = config.services.ntp;

  configFile = pkgs.writeText "ntp.conf" ''
    driftfile /var/lib/ntp/ntp.drift

    restrict default ${toString cfg.restrictDefault}
    restrict -6 default ${toString cfg.restrictDefault}
    restrict source ${toString cfg.restrictSource}

    restrict 127.0.0.1
    restrict -6 ::1

    ${toString (
      map (
        server: "${if lib.strings.hasInfix "pool" server then "pool" else "server"} " + server + " iburst\n"
      ) cfg.servers
    )}

    ${cfg.extraConfig}
  '';

  ntpFlags = [
    "-c"
    "${configFile}"
    "-u"
    "ntp:ntp"
  ]
  ++ cfg.extraFlags;

in

{

  ###### interface
  options = {

    services.ntp = {

      enable = mkOption {
        default = false;

        description = ''
          Whether to synchronise your machine's time using ntpd, as a peer in
          the NTP network.

          Disables `systemd.timesyncd` if enabled.
        '';

        type = types.bool;
      };

      extraConfig = mkOption {
        default = "";

        description = ''
          Additional text appended to {file}`ntp.conf`.
        '';

        example = ''
          fudge 127.127.1.0 stratum 10
        '';

        type = types.lines;
      };

      extraFlags = mkOption {
        default = [ ];
        description = "Extra flags passed to the ntpd command.";
        example = literalExpression ''[ "--interface=eth0" ]'';
        type = types.listOf types.str;
      };

      restrictDefault = mkOption {
        default = [
          "limited"
          "kod"
          "nomodify"
          "notrap"
          "noquery"
          "nopeer"
        ];

        description = ''
          The restriction flags to be set by default.

          The default flags prevent external hosts from using ntpd as a DDoS
          reflector, setting system time, and querying OS/ntpd version. As
          recommended in section 6.5.1.1.3, answer "No" of
          https://support.ntp.org/Support/AccessRestrictions
        '';

        type = types.listOf types.str;
      };

      restrictSource = mkOption {
        default = [
          "limited"
          "kod"
          "nomodify"
          "notrap"
          "noquery"
        ];

        description = ''
          The restriction flags to be set on source.

          The default flags allow peers to be added by ntpd from configured
          pool(s), but not by other means.
        '';

        type = types.listOf types.str;
      };

      servers = mkOption {
        default = config.networking.timeServers;
        defaultText = literalExpression "config.networking.timeServers";

        description = ''
          The set of NTP servers from which to synchronise.
        '';

        type = types.listOf types.str;
      };

    };

  };

  config = mkIf config.services.ntp.enable {
    # Make tools such as ntpq available in the system path.
    environment.systemPackages = [ pkgs.ntp ];
    services.timesyncd.enable = mkForce false;

    systemd.services.ntpd = {
      before = [ "time-sync.target" ];
      description = "NTP Daemon";

      serviceConfig = {
        AmbientCapabilities = [
          "CAP_SYS_TIME"
        ];

        ExecStart = "@${ntp}/bin/ntpd ntpd -g ${toString ntpFlags}";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        # Hardening options
        PrivateDevices = true;
        PrivateIPC = true;
        PrivateTmp = true;
        ProcSubset = "pid";
        ProtectClock = false;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        Type = "forking";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "time-sync.target" ];
    };

    systemd.services.systemd-timedated.environment = {
      SYSTEMD_TIMEDATED_NTP_SERVICES = "ntpd.service";
    };

    users.groups.ntp = { };

    users.users.ntp = {
      createHome = true;
      description = "NTP daemon user";
      group = "ntp";
      home = "/var/lib/ntp";
      isSystemUser = true;
    };

  };

  ###### implementation
  meta.maintainers = with lib.maintainers; [ thoughtpolice ];

}
