{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.minidlna;
  format = pkgs.formats.keyValue { listsAsDuplicateKeys = true; };
  cfgfile = format.generate "minidlna.conf" cfg.settings;

  # Match a media_dir entry under /home, allowing an optional `A,`/`V,`/`P,`
  # media-type prefix.
  mediaDirsUnderHome = lib.any (
    dir: builtins.match "([AVP],)?/home/.*" dir != null
  ) cfg.settings.media_dir;

in
{
  options.services.minidlna.enable = lib.mkEnableOption "MiniDLNA, a simple DLNA server. Consider adding `openFirewall = true` into your config";
  options.services.minidlna.openFirewall = lib.mkEnableOption "opening HTTP (TCP) and SSDP (UDP) ports in the firewall";
  options.services.minidlna.package = lib.mkPackageOption pkgs "minidlna" { };

  options.services.minidlna.settings = lib.mkOption {
    default = { };
    description = "Configuration for {manpage}`minidlna.conf(5)`.";

    type = lib.types.submodule {
      options.db_dir = lib.mkOption {
        default = "/var/cache/minidlna";
        description = "Specify the directory to store database and album art cache.";
        example = "/tmp/minidlna";
        type = lib.types.path;
      };

      options.enable_subtitles = lib.mkOption {
        default = "yes";
        description = "Enable subtitle support on unknown clients.";

        type = lib.types.enum [
          "yes"
          "no"
        ];
      };

      options.enable_tivo = lib.mkOption {
        default = "no";
        description = "Support for streaming .jpg and .mp3 files to a TiVo supporting HMO.";

        type = lib.types.enum [
          "yes"
          "no"
        ];
      };

      options.friendly_name = lib.mkOption {
        default = config.networking.hostName;
        defaultText = lib.literalExpression "config.networking.hostName";
        description = "Name that the server presents to clients.";
        example = "rpi3";
        type = lib.types.str;
      };

      options.inotify = lib.mkOption {
        default = "no";
        description = "Whether to enable inotify monitoring to automatically discover new files.";

        type = lib.types.enum [
          "yes"
          "no"
        ];
      };

      options.log_level = lib.mkOption {
        default = "warn";
        description = "Defines the type of messages that should be logged and down to which level of importance.";
        example = "general,artwork,database,inotify,scanner,metadata,http,ssdp,tivo=warn";
        type = lib.types.str;
      };

      options.media_dir = lib.mkOption {
        default = [ ];

        description = ''
          Directories to be scanned for media files.
          The `A,` `V,` `P,` prefixes restrict a directory to audio, video or image files.
          The directories must be accessible to the `minidlna` user account.
        '';

        example = [
          "/data/media"
          "V,/home/alice/video"
        ];

        type = lib.types.listOf lib.types.str;
      };

      options.notify_interval = lib.mkOption {
        default = 90000;

        description = ''
          The interval between announces (in seconds).
          Instead of waiting for announces, you should set `openFirewall` option to use SSDP discovery.
          Lower values (e.g. 30 seconds) should be used if your network is blocking the SSDP multicast.
          Some relevant information can be found [here](https://sourceforge.net/p/minidlna/discussion/879957/thread/1389d197/).
        '';

        type = lib.types.int;
      };

      options.port = lib.mkOption {
        default = 8200;
        description = "Port number for HTTP traffic (descriptions, SOAP, media transfer).";
        type = lib.types.port;
      };

      options.root_container = lib.mkOption {
        default = "B";
        description = "Use a different container as the root of the directory tree presented to clients.";
        example = ".";
        type = lib.types.str;
      };

      options.wide_links = lib.mkOption {
        default = "no";
        description = "Set this to yes to allow symlinks that point outside user-defined `media_dir`.";

        type = lib.types.enum [
          "yes"
          "no"
        ];
      };

      freeformType = format.type;
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.settings.port ];
    networking.firewall.allowedUDPPorts = lib.mkIf cfg.openFirewall [ 1900 ];

    systemd.services.minidlna = {
      after = [ "network.target" ];
      description = "MiniDLNA Server";

      serviceConfig = {
        # Hardening
        AmbientCapabilities = [ "" ];
        CacheDirectory = "minidlna";
        CapabilityBoundingSet = [ "" ];
        DeviceAllow = [ "" ];
        ExecStart = "${lib.getExe cfg.package} -S -P /run/minidlna/pid -f ${cfgfile}";
        Group = "minidlna";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PIDFile = "/run/minidlna/pid";
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        # Many users keep media under /home; auto-disable ProtectHome when
        # any media_dir entry is under /home. Override explicitly to force.
        ProtectHome = lib.mkDefault (!mediaDirsUnderHome);
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RemoveIPC = true;

        # AF_NETLINK is required for getifaddrs() to enumerate interfaces
        # for SSDP multicast (239.255.255.250:1900) advertisements.
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = "minidlna";
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];

        UMask = "0077";
        User = "minidlna";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.minidlna.gid = config.ids.gids.minidlna;

    users.users.minidlna = {
      description = "MiniDLNA daemon user";
      group = "minidlna";
      uid = config.ids.uids.minidlna;
    };
  };
}
