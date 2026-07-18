{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    getExe
    literalExpression
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    optionalString
    toUpper
    types
    ;

  cfg = config.services.stash;

  stashType = types.submodule {
    options = {
      excludeimage = mkOption {
        default = false;
        description = "Whether to exclude image files from being scanned into Stash";
        type = types.bool;
      };

      excludevideo = mkOption {
        default = false;
        description = "Whether to exclude video files from being scanned into Stash";
        type = types.bool;
      };

      path = mkOption {
        description = "location of your media files";
        type = types.path;
      };
    };
  };
  stashBoxType = types.submodule {
    options = {
      apikey = mkOption {
        description = "Stash Box API key";
        type = types.str;
      };

      endpoint = mkOption {
        description = "URL to the Stash Box graphql api";
        type = types.str;
      };

      name = mkOption {
        description = "The name of the Stash Box";
        type = types.str;
      };
    };
  };

  recentlyReleased = mode: {
    __typename = "CustomFilter";
    direction = "DESC";

    message = {
      id = "recently_released_objects";
      values.objects = mode;
    };

    mode = toUpper mode;
    sortBy = "date";
  };
  recentlyAdded = mode: {
    __typename = "CustomFilter";
    direction = "DESC";

    message = {
      id = "recently_added_objects";
      values.objects = mode;
    };

    mode = toUpper mode;
    sortBy = "created_at";
  };
  uiPresets = {
    recentlyAddedGalleries = recentlyAdded "Galleries";
    recentlyAddedImages = recentlyAdded "Images";
    recentlyAddedMovies = recentlyAdded "Movies";
    recentlyAddedPerformers = recentlyAdded "Performers";
    recentlyAddedScenes = recentlyAdded "Scenes";
    recentlyAddedStudios = recentlyAdded "Studios";
    recentlyReleasedGalleries = recentlyReleased "Galleries";
    recentlyReleasedMovies = recentlyReleased "Movies";
    recentlyReleasedScenes = recentlyReleased "Scenes";
  };

  settingsFormat = pkgs.formats.yaml { };
  settingsFile = settingsFormat.generate "config.yml" cfg.settings;
  settingsType = types.submodule {
    options = {
      blobs_path = mkOption {
        default = "${cfg.dataDir}/blobs";
        description = "Path to blobs";
        type = types.path;
      };

      blobs_storage = mkOption {
        default = "FILESYSTEM";
        description = "Where to store blobs";

        type = types.enum [
          "FILESYSTEM"
          "DATABASE"
        ];
      };

      cache = mkOption {
        default = "${cfg.dataDir}/cache";
        description = "Path to cache";
        type = types.path;
      };

      calculate_md5 = mkOption {
        default = false;
        description = "Whether to calculate MD5 checksums for scene video files";
        type = types.bool;
      };

      create_image_clip_from_videos = mkOption {
        default = false;
        description = "Create Image Clips from Video extensions when Videos are disabled in Library";
        type = types.bool;
      };

      dangerous_allow_public_without_auth = mkOption {
        default = false;
        description = "Learn more at <https://docs.stashapp.cc/networking/authentication-required-when-accessing-stash-from-the-internet/>";
        type = types.bool;
      };

      database = mkOption {
        default = "${cfg.dataDir}/go.sqlite";
        description = "Path to the SQLite database";
        type = types.path;
      };

      gallery_cover_regex = mkOption {
        default = "(poster|cover|folder|board)\\.[^.]+$";
        description = "Regex used to identify images as gallery covers";
        type = types.str;
      };

      generated = mkOption {
        default = "${cfg.dataDir}/generated";
        description = "Path to generated files";
        type = types.path;
      };

      host = mkOption {
        default = "localhost";
        description = "The ip address that Stash should bind to.";
        example = "::1";
        type = types.str;
      };

      no_proxy = mkOption {
        default = "localhost,127.0.0.1,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12";
        description = "A list of domains for which the proxy must not be used";
        type = types.str;
      };

      nobrowser = mkOption {
        default = true;
        description = "If we should not auto-open a browser window on startup";
        type = types.bool;
      };

      notifications_enabled = mkOption {
        default = true;
        description = "If we should send notifications to the desktop";
        type = types.bool;
      };

      parallel_tasks = mkOption {
        default = 1;
        description = "Number of parallel tasks to start during scan/generate";
        type = types.int;
      };

      plugins_path = mkOption {
        default = "${cfg.dataDir}/plugins";
        description = "Path to scrapers";
        type = types.path;
      };

      port = mkOption {
        default = 9999;
        description = "The port that Stash should listen on.";
        example = 1234;
        type = types.port;
      };

      preview_audio = mkOption {
        default = true;
        description = "Include audio stream in previews";
        type = types.bool;
      };

      preview_exclude_end = mkOption {
        default = 0;
        description = "Duration of start of video to exclude when generating previews";
        type = types.int;
      };

      preview_exclude_start = mkOption {
        default = 0;
        description = "Duration of end of video to exclude when generating previews";
        type = types.int;
      };

      preview_segment_duration = mkOption {
        default = 0.75;
        description = "Preview segment duration, in seconds";
        type = types.float;
      };

      preview_segments = mkOption {
        default = 12;
        description = "Number of segments in a preview file";
        type = types.int;
      };

      scrapers_path = mkOption {
        default = "${cfg.dataDir}/scrapers";
        description = "Path to scrapers";
        type = types.path;
      };

      security_tripwire_accessed_from_public_internet = mkOption {
        default = "";
        description = "Learn more at <https://docs.stashapp.cc/networking/authentication-required-when-accessing-stash-from-the-internet/>";
        type = types.nullOr types.str;
      };

      sequential_scanning = mkOption {
        default = false;
        description = "Modifies behaviour of the scanning functionality to generate support files (previews/sprites/phash) at the same time as fingerprinting/screenshotting";
        type = types.bool;
      };

      show_one_time_moved_notification = mkOption {
        default = true;
        description = "Whether a small notification to inform the user that Stash will no longer show a terminal window, and instead will be available in the tray";
        type = types.bool;
      };

      sound_on_preview = mkOption {
        default = false;
        description = "Enable sound on mouseover previews";
        type = types.bool;
      };

      stash = mkOption {
        description = ''
          Add directories containing your adult videos and images.
          Stash will use these directories to find videos and/or images during scanning.
        '';

        example = literalExpression ''
          {
            stash = [
              {
                Path = "/media/drive/videos";
                ExcludeImage = true;
              }
            ];
          }
        '';

        type = types.listOf stashType;
      };

      stash_boxes = mkOption {
        default = [ ];
        description = "Stash-box facilitates automated tagging of scenes and performers based on fingerprints and filenames";

        example = literalExpression ''
          {
            stash_boxes = [
              {
                name = "StashDB";
                endpoint = "https://stashdb.org/graphql";
                apikey = "aaaaaaaaaaaa.bbbbbbbbbbbbbbbbbbbbbbbb.cccccccccccccc";
              }
            ];
          }
        '';

        type = types.listOf stashBoxType;
      };

      theme_color = mkOption {
        default = "#202b33";
        description = "Sets the `theme-color` property in the UI";
        type = types.str;
      };

      ui.frontPageContent = mkOption {
        apply = type: if lib.isFunction type then (type uiPresets) else type;

        default = presets: [
          presets.recentlyReleasedScenes
          presets.recentlyAddedStudios
          presets.recentlyReleasedMovies
          presets.recentlyAddedPerformers
          presets.recentlyReleasedGalleries
        ];

        description = "Search filters to display on the front page.";

        example = literalExpression ''
          presets: [
            # To get the savedFilterId, you can query `{ findSavedFilters(mode: <FilterMode>) { id name } }` on localhost:9999/graphql
            {
              __typename = "SavedFilter";
              savedFilterId = 1;
            }
            # basic custom filter
            {
              __typename = "CustomFilter";
              title = "Random Scenes";
              mode = "SCENES";
              sortBy = "random";
              direction = "DESC";
            }
            presets.recentlyAddedImages
          ]
        '';

        type = types.either (types.listOf types.attrs) (types.functionTo (types.listOf types.attrs));
      };

      video_file_naming_algorithm = mkOption {
        default = "OSHASH";
        description = "Hash algorithm to use for generated file naming";

        type = types.enum [
          "OSHASH"
          "MD5"
        ];
      };

      write_image_thumbnails = mkOption {
        default = true;
        description = "Write image thumbnails to disk when generating on the fly";
        type = types.bool;
      };
    };

    freeformType = settingsFormat.type;
  };

  pluginType =
    kind:
    mkOption {
      apply =
        srcs:
        pkgs.runCommand "stash-${kind}"
          {
            inherit srcs;
            nativeBuildInputs = [ pkgs.yq-go ];
            preferLocalBuild = true;
          }
          ''
            mkdir -p $out
            touch $out/.keep
            find $srcs -mindepth 1 -name '*.yml' | while read plugin_file; do
              grep -q "^#pkgignore" "$plugin_file" && continue

              plugin_dir=$(dirname $plugin_file)
              out_path=$out/$(basename $plugin_dir)
              mkdir -p $out_path
              ls $plugin_dir | xargs -I{} ln -sf "$plugin_dir/{}" $out_path

              env \
                plugin_id=$(basename $plugin_file .yml) \
                plugin_name="$(yq '.name' $plugin_file)" \
                plugin_description="$(yq '.description' $plugin_file)" \
                plugin_version="$(yq '.version' $plugin_file)" \
                plugin_files="$(find -L $out_path -mindepth 1 -type f -printf "%P\n")" \
                yq -n '
                  .id = strenv(plugin_id) |
                  .name = strenv(plugin_name) |
                  (
                    strenv(plugin_description) as $desc |
                    with(select($desc == "null"); .metadata = {}) |
                    with(select($desc != "null"); .metadata.description = $desc)
                  ) |
                  (
                    strenv(plugin_version) as $ver |
                    with(select($ver == "null"); .version = "Unknown") |
                    with(select($ver != "null"); .version = $ver)
                  ) |
                  .date = (now | format_datetime("2006-01-02 15:04:05")) |
                  .files = (strenv(plugin_files) | split("\n"))
                ' > $out_path/manifest
            done
          '';

      default = [ ];

      description = ''
        The ${kind} Stash should be started with.
      '';

      type = types.listOf types.package;
    };
in
{
  options = {
    services.stash = {
      enable = mkEnableOption "stash";
      package = mkPackageOption pkgs "stash" { };

      dataDir = mkOption {
        default = "/var/lib/stash";
        description = "The directory where Stash stores its files.";
        type = types.path;
      };

      group = mkOption {
        default = "stash";
        description = "Group under which Stash runs.";
        type = types.str;
      };

      jwtSecretKeyFile = mkOption {
        description = "Path to file containing a secret used to sign JWT tokens.";
        type = types.path;
      };

      mutablePlugins = mkEnableOption "Whether plugins/themes can be installed, updated, uninstalled manually.";
      mutableScrapers = mkEnableOption "Whether scrapers can be installed, updated, uninstalled manually.";

      mutableSettings = mkOption {
        default = true;

        description = ''
          Whether the Stash config.yml is writeable by Stash.

          If `false`, Any config changes done from within Stash UI will be temporary and reset to those defined in {option}`services.stash.settings` upon `Stash.service` restart.
          If `true`, the {option}`services.stash.settings` will only be used to initialize the Stash configuration if it does not exist, and are subsequently ignored.
        '';

        type = types.bool;
      };

      openFirewall = mkOption {
        default = false;
        description = "Open ports in the firewall for the Stash web interface.";
        type = types.bool;
      };

      passwordFile = mkOption {
        default = null;

        description = ''
          Path to file containing password for login.

          ::: {.warning}
            This option takes precedence over {option}`services.stash.settings.password`
          ::

        '';

        example = "/path/to/password/file";
        type = types.nullOr types.path;
      };

      plugins = pluginType "plugins";
      scrapers = pluginType "scrapers";

      sessionStoreKeyFile = mkOption {
        description = "Path to file containing a secret for session store.";
        type = types.path;
      };

      settings = mkOption {
        description = "Stash configuration";
        type = settingsType;
      };

      user = mkOption {
        default = "stash";
        description = "User under which Stash runs.";
        type = types.str;
      };

      username = mkOption {
        default = null;

        description = ''
          Username for login.

          ::: {.warning}
            This option takes precedence over {option}`services.stash.settings.username`
          ::

        '';

        example = "admin";
        type = types.nullOr types.nonEmptyStr;
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion =
          !lib.xor (cfg.username != null || cfg.settings.username or null != null) (
            cfg.passwordFile != null || cfg.settings.password or null != null
          );

        message = "You must set either both username and password, or neither.";
      }
    ];

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.settings.port ];

    services.stash.settings = {
      plugins_path = mkIf (!cfg.mutablePlugins) cfg.plugins;
      scrapers_path = mkIf (!cfg.mutableScrapers) cfg.scrapers;
      username = mkIf (cfg.username != null) cfg.username;
    };

    systemd = {
      services.stash = {
        after = [ "network.target" ];
        environment.STASH_CONFIG_FILE = "${cfg.dataDir}/config.yml";

        path = with pkgs; [
          ffmpeg-full
          python3
          ruby
        ];

        serviceConfig = {
          AmbientCapabilities = [ "" ];
          BindReadOnlyPaths = mkIf (cfg.settings != { }) (map (stash: "${stash.path}") cfg.settings.stash);
          CapabilityBoundingSet = [ "" ];
          # hardening
          DevicePolicy = "auto"; # needed for hardware acceleration
          DynamicUser = false;
          ExecStart = getExe cfg.package;

          ExecStartPre = pkgs.writers.writeBash "stash-setup.bash" (
            ''
              install -d ${cfg.settings.generated}
              if [[ -z "${toString cfg.mutableSettings}" || ! -f ${cfg.dataDir}/config.yml ]]; then
                env \
                  password=$(< ${cfg.passwordFile}) \
                  jwtSecretKeyFile=$(< ${cfg.jwtSecretKeyFile}) \
                  sessionStoreKeyFile=$(< ${cfg.sessionStoreKeyFile}) \
                  ${lib.getExe pkgs.yq-go} '
                    .jwt_secret_key = strenv(jwtSecretKeyFile) |
                    .session_store_key = strenv(sessionStoreKeyFile) |
                    (
                      strenv(password) as $password |
                      with(select($password != ""); .password = $password)
                    )
                  ' ${settingsFile} > ${cfg.dataDir}/config.yml
              fi
            ''
            + optionalString cfg.mutablePlugins ''
              install -d ${cfg.settings.plugins_path}
              ls ${cfg.plugins} | xargs -I{} ln -sf '${cfg.plugins}/{}' ${cfg.settings.plugins_path}
            ''
            + optionalString cfg.mutableScrapers ''
              install -d ${cfg.settings.scrapers_path}
              ls ${cfg.scrapers} | xargs -I{} ln -sf '${cfg.scrapers}/{}' ${cfg.settings.scrapers_path}
            ''
          );

          Group = cfg.group;
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = false; # needed for hardware acceleration
          PrivateTmp = true;
          PrivateUsers = true;
          ProcSubset = "pid";
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = "tmpfs";
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "full";
          RemoveIPC = true;
          Restart = "on-failure";

          RestrictAddressFamilies = [
            "AF_UNIX"
            "AF_INET"
            "AF_INET6"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          StateDirectory = mkIf (cfg.dataDir == "/var/lib/stash") (baseNameOf cfg.dataDir);
          SystemCallArchitectures = "native";

          SystemCallFilter = [
            "~@cpu-emulation"
            "~@debug"
            "~@mount"
            "~@obsolete"
            "~@privileged"
          ];

          User = cfg.user;
          WorkingDirectory = cfg.dataDir;
        };

        wantedBy = [ "multi-user.target" ];
      };

      tmpfiles.settings."10-stash-datadir".${cfg.dataDir}."d" = {
        inherit (cfg) user group;
        mode = "0755";
      };
    };

    users.groups.${cfg.group} = { };

    users.users.${cfg.user} = {
      inherit (cfg) group;
      home = cfg.dataDir;
      isSystemUser = true;
    };
  };

  meta = {
    buildDocsInSandbox = false;
    maintainers = with lib.maintainers; [ DrakeTDL ];
  };
}
