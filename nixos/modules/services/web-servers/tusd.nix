{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.tusd;
  username = "tusd";
  groupname = "tusd";

  args = [
    "-host=${cfg.host}"
    "-port=${toString cfg.port}"
    "-base-path=${cfg.basePath}"
    "-upload-dir=${cfg.uploadDir}"
  ]
  ++ lib.optional cfg.behindProxy "-behind-proxy"
  ++ lib.optional (cfg.maxSize != null) "-max-size=${toString cfg.maxSize}"
  ++ lib.optional (cfg.networkTimeout != null) "-network-timeout=${cfg.networkTimeout}"
  ++ lib.optional (cfg.hooksHttp != null) "-hooks-http=${cfg.hooksHttp}"
  ++ lib.optional (
    cfg.hooksEnabledEvents != [ ]
  ) "-hooks-enabled-events=${lib.concatStringsSep "," cfg.hooksEnabledEvents}"
  ++ cfg.extraArgs;
in
{
  options.services.tusd = {
    enable = lib.mkEnableOption "tus resumable upload protocol server";

    basePath = lib.mkOption {
      default = "/files/";
      description = "The basepath of the HTTP server.";
      type = lib.types.str;
    };

    behindProxy = lib.mkEnableOption null // {
      description = "Whether to respect X-Forwarded-* and similar headers which may be set by proxies.";
    };

    extraArgs = lib.mkOption {
      default = [ ];
      description = "Additional arguments given to tusd.";

      example = [
        "-verbose"
        "-log-format=json"
      ];

      type = lib.types.listOf lib.types.str;
    };

    hooksEnabledEvents = lib.mkOption {
      default = [ ];
      description = "The list of enabled hook events.";

      example = [
        "pre-create"
        "post-finish"
      ];

      type = lib.types.listOf lib.types.str;
    };

    hooksHttp = lib.mkOption {
      default = null;
      description = "The HTTP endpoint to which hook events will be sent to.";
      example = "http://localhost:8081/hooks";
      type = lib.types.nullOr lib.types.str;
    };

    host = lib.mkOption {
      default = "0.0.0.0";
      description = "The host to bind the HTTP server to.";
      type = lib.types.str;
    };

    maxSize = lib.mkOption {
      default = null;
      description = "The maximum size of a single upload in bytes.";
      type = lib.types.nullOr lib.types.int;
    };

    networkTimeout = lib.mkOption {
      default = null;

      description = ''
        The timeout for reading the request and writing the response.
        If tusd does not receive data for this duration,
        it will consider the connection dead.
      '';

      example = "30s";
      type = lib.types.nullOr lib.types.str;
    };

    openFirewall = lib.mkOption {
      default = false;
      description = "Whether to open the firewall port for tusd.";
      type = lib.types.bool;
    };

    port = lib.mkOption {
      default = 8080;
      description = "The port to bind the HTTP server to.";
      type = lib.types.port;
    };

    uploadDir = lib.mkOption {
      default = "/var/lib/tusd/data";
      description = "The directory to store uploads in.";
      type = lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.optional cfg.openFirewall cfg.port;

    systemd.services.tusd = {
      after = [ "network.target" ];
      description = "tusd - tus resumable upload protocol server";
      documentation = [ "https://github.com/tus/tusd" ];

      serviceConfig = {
        ExecStart = lib.escapeShellArgs ([ (lib.getExe pkgs.tusd) ] ++ args);
        Group = groupname;
        # Hardening
        LockPersonality = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHostUserNamespaces = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        Restart = "on-failure";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "tusd";
        User = username;
      };

      wantedBy = [ "multi-user.target" ];
    };

    # tusd knows how to create subdirectories in this folder but we have to
    # create the root folder ourselves.
    systemd.tmpfiles.settings."tusd".${cfg.uploadDir}.d = {
      group = groupname;
      # default taken from https://github.com/tus/tusd/blob/55a096a10942b85360664a1e8aea7bd758272053/pkg/filestore/filestore.go#L37
      mode = "0775";
      user = username;
    };

    users.groups.${groupname} = { };

    users.users.${username} = {
      group = groupname;
      isSystemUser = true;
    };
  };

  meta.maintainers = with lib.maintainers; [ m1-s ];
}
