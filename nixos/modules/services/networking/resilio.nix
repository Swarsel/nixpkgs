{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.resilio;

  sharedFoldersRecord = map (entry: {
    dir = entry.directory;
    known_hosts = entry.knownHosts;
    search_lan = entry.searchLAN;
    use_dht = entry.useDHT;
    use_relay_server = entry.useRelayServer;
    use_sync_trash = entry.useSyncTrash;
    use_tracker = entry.useTracker;
  }) cfg.sharedFolders;

  configFile = pkgs.writeText "config.json" (
    builtins.toJSON (
      {
        check_for_updates = cfg.checkForUpdates;
        device_name = cfg.deviceName;
        download_limit = cfg.downloadLimit;
        lan_encrypt_data = cfg.encryptLAN;
        listening_port = cfg.listeningPort;
        storage_path = cfg.storagePath;
        upload_limit = cfg.uploadLimit;
        use_gui = false;
        use_upnp = cfg.useUpnp;
      }
      // optionalAttrs (cfg.directoryRoot != "") { directory_root = cfg.directoryRoot; }
      // optionalAttrs cfg.enableWebUI {
        webui = {
          listen = "${cfg.httpListenAddr}:${toString cfg.httpListenPort}";
        }
        // (optionalAttrs (cfg.httpLogin != "") { login = cfg.httpLogin; })
        // (optionalAttrs (cfg.httpPass != "") { password = cfg.httpPass; })
        // (optionalAttrs (cfg.apiKey != "") { api_key = cfg.apiKey; });
      }
      // optionalAttrs (sharedFoldersRecord != [ ]) {
        shared_folders = sharedFoldersRecord;
      }
    )
  );

  sharedFoldersSecretFiles = map (entry: {
    dir = entry.directory;

    secretFile =
      if builtins.hasAttr "secret" entry then
        toString (
          pkgs.writeTextFile {
            name = "secret-file";
            text = entry.secret;
          }
        )
      else
        entry.secretFile;
  }) cfg.sharedFolders;

  runConfigPath = "/run/rslsync/config.json";

  createConfig = pkgs.writeShellScriptBin "create-resilio-config" (
    if cfg.sharedFolders != [ ] then
      ''
        ${pkgs.jq}/bin/jq \
          '.shared_folders |= map(.secret = $ARGS.named[.dir])' \
          ${
            lib.concatMapStringsSep " \\\n  " (
              entry: ''--arg '${entry.dir}' "$(cat '${entry.secretFile}')"''
            ) sharedFoldersSecretFiles
          } \
          <${configFile} \
          >${runConfigPath}
      ''
    else
      ''
        # no secrets, passing through config
        cp ${configFile} ${runConfigPath};
      ''
  );

in
{
  options = {
    services.resilio = {
      enable = mkOption {
        default = false;

        description = ''
          If enabled, start the Resilio Sync daemon. Once enabled, you can
          interact with the service through the Web UI, or configure it in your
          NixOS configuration.
        '';

        type = types.bool;
      };

      package = mkPackageOption pkgs "resilio-sync" { };

      apiKey = mkOption {
        default = "";
        description = "API key, which enables the developer API.";
        type = types.str;
      };

      checkForUpdates = mkOption {
        default = true;

        description = ''
          Determines whether to check for updates and alert the user
          about them in the UI.
        '';

        type = types.bool;
      };

      deviceName = mkOption {
        default = config.networking.hostName;
        defaultText = literalExpression "config.networking.hostName";

        description = ''
          Name of the Resilio Sync device.
        '';

        example = "Voltron";
        type = types.str;
      };

      directoryRoot = mkOption {
        default = "";
        description = "Default directory to add folders in the web UI.";
        example = "/media";
        type = types.str;
      };

      downloadLimit = mkOption {
        default = 0;

        description = ''
          Download speed limit. 0 is unlimited (default).
        '';

        example = 1024;
        type = types.ints.unsigned;
      };

      enableWebUI = mkOption {
        default = false;

        description = ''
          Enable Web UI for administration. Bound to the specified
          `httpListenAddress` and
          `httpListenPort`.
        '';

        type = types.bool;
      };

      encryptLAN = mkOption {
        default = true;
        description = "Encrypt LAN data.";
        type = types.bool;
      };

      httpListenAddr = mkOption {
        default = "[::1]";

        description = ''
          HTTP address to bind to.
        '';

        example = "0.0.0.0";
        type = types.str;
      };

      httpListenPort = mkOption {
        default = 9000;

        description = ''
          HTTP port to bind on.
        '';

        type = types.port;
      };

      httpLogin = mkOption {
        default = "";

        description = ''
          HTTP web login username.
        '';

        example = "allyourbase";
        type = types.str;
      };

      httpPass = mkOption {
        default = "";

        description = ''
          HTTP web login password.
        '';

        example = "arebelongtous";
        type = types.str;
      };

      listeningPort = mkOption {
        default = 0;

        description = ''
          Listening port. Defaults to 0 which randomizes the port.
        '';

        example = 44444;
        type = types.port;
      };

      sharedFolders = mkOption {
        default = [ ];

        description = ''
          Shared folder list. If enabled, web UI must be
          disabled. Secrets can be generated using `rslsync --generate-secret`.

          If you would like to be able to modify the contents of this
          directories, it is recommended that you make your user a
          member of the `rslsync` group.

          Directories in this list should be in the
          `rslsync` group, and that group must have
          write access to the directory. It is also recommended that
          `chmod g+s` is applied to the directory
          so that any sub directories created will also belong to
          the `rslsync` group. Also,
          `setfacl -d -m group:rslsync:rwx` and
          `setfacl -m group:rslsync:rwx` should also
          be applied so that the sub directories are writable by
          the group.
        '';

        example = [
          {
            directory = "/home/user/sync_test";

            knownHosts = [
              "192.168.1.2:4444"
              "192.168.1.3:4444"
            ];

            searchLAN = true;
            secretFile = "/run/resilio-secret";
            useDHT = false;
            useRelayServer = true;
            useSyncTrash = true;
            useTracker = true;
          }
        ];

        type = types.listOf (types.attrsOf types.anything);
      };

      storagePath = mkOption {
        default = "/var/lib/resilio-sync/";

        description = ''
          Where BitTorrent Sync will store it's database files (containing
          things like username info and licenses). Generally, you should not
          need to ever change this.
        '';

        type = types.path;
      };

      uploadLimit = mkOption {
        default = 0;

        description = ''
          Upload speed limit. 0 is unlimited (default).
        '';

        example = 1024;
        type = types.ints.unsigned;
      };

      useUpnp = mkOption {
        default = true;

        description = ''
          Use Universal Plug-n-Play (UPnP)
        '';

        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.deviceName != "";
        message = "Device name cannot be empty.";
      }
      {
        assertion = cfg.enableWebUI -> cfg.sharedFolders == [ ];
        message = "If using shared folders, the web UI cannot be enabled.";
      }
      {
        assertion = cfg.apiKey != "" -> cfg.enableWebUI;
        message = "If you're using an API key, you must enable the web server.";
      }
    ];

    systemd.services.resilio = {
      after = [ "network.target" ];
      description = "Resilio Sync Service";

      serviceConfig = {
        ExecStart = ''
          ${lib.getExe cfg.package} --nodaemon --config ${runConfigPath}
        '';

        ExecStartPre = "${createConfig}/bin/create-resilio-config";
        Restart = "on-abort";
        RuntimeDirectory = "rslsync";
        UMask = "0002";
        User = "rslsync";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.rslsync.gid = config.ids.gids.rslsync;

    users.users.rslsync = {
      createHome = true;
      description = "Resilio Sync Service user";
      group = "rslsync";
      home = cfg.storagePath;
      uid = config.ids.uids.rslsync;
    };
  };

  meta.maintainers = [ ];
}
