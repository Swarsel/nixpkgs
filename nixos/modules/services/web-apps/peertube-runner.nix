{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.peertube-runner;

  settingsFormat = pkgs.formats.toml { };
  configFile = settingsFormat.generate "config.toml" cfg.settings;

  env = {
    NODE_ENV = "production";
    XDG_CACHE_HOME = "/var/cache/peertube-runner";
    XDG_CONFIG_HOME = "/var/lib/peertube-runner";
    # peertube-runner makes its IPC socket in $XDG_DATA_HOME.
    XDG_DATA_HOME = "/run/peertube-runner";
  };
in
{
  options.services.peertube-runner = {
    enable = lib.mkEnableOption "peertube-runner";
    package = lib.mkPackageOption pkgs [ "peertube" "runner" ] { };

    enabledJobTypes = lib.mkOption {
      default = [
        "vod-web-video-transcoding"
        "vod-hls-transcoding"
        "vod-audio-merge-transcoding"
        "live-rtmp-hls-transcoding"
        "video-studio-transcoding"
        "video-transcription"
      ];

      description = "Job types that this runner will execute.";
      example = [ "video-transcription" ];
      type = with lib.types; nonEmptyListOf str;
    };

    group = lib.mkOption {
      default = "prunner";
      description = "Group under which peertube-runner runs.";
      example = "peertube-runner";
      type = lib.types.str;
    };

    instancesToRegister = lib.mkOption {
      default = { };
      description = "PeerTube instances to register this runner with.";

      example = {
        personal = {
          registrationTokenFile = "/run/secrets/my-peertube-instance-registration-token";
          runnerDescription = "Runner for video transcription";
          runnerName = "Transcription";
          url = "https://mypeertubeinstance.com";
        };
      };

      type =
        with lib.types;
        attrsOf (submodule {
          options = {
            registrationTokenFile = lib.mkOption {
              description = ''
                Path to a file containing a registration token for the PeerTube instance.

                See how to generate registration tokens at <https://docs.joinpeertube.org/admin/remote-runners#manage-remote-runners>.
              '';

              example = "/run/secrets/my-peertube-instance-registration-token";
              type = lib.types.path;
            };

            runnerDescription = lib.mkOption {
              default = null;
              description = "Runner description declared to the PeerTube instance.";
              example = "Runner for video transcription";
              type = with lib.types; nullOr str;
            };

            runnerName = lib.mkOption {
              description = "Runner name declared to the PeerTube instance.";
              example = "Transcription";
              type = lib.types.str;
            };

            url = lib.mkOption {
              description = "URL of the PeerTube instance.";
              example = "https://mypeertubeinstance.com";
              type = lib.types.str;
            };
          };
        });
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration for peertube-runner.

        See available configuration options at <https://docs.joinpeertube.org/maintain/tools#configuration>.
      '';

      example = lib.literalExpression ''
        {
          jobs.concurrency = 4;
          ffmpeg = {
            threads = 0; # Let ffmpeg automatically choose.
            nice = 5;
          };
          transcription.model = "large-v3";
        }
      '';

      type = settingsFormat.type;
    };

    user = lib.mkOption {
      default = "prunner";
      description = "User account under which peertube-runner runs.";
      example = "peertube-runner";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !(cfg.settings ? registeredInstances);

        message = ''
          `services.peertube-runner.settings.registeredInstances` cannot be used.
          Instead, registered instances can be configured with `services.peertube-runner.instancesToRegister`.
        '';
      }
    ];

    environment.systemPackages = [
      (pkgs.writeShellScriptBin "peertube-runner" ''
        ${lib.concatMapAttrsStringSep "\n" (name: value: ''export ${name}="${toString value}"'') env}

        if [[ "$USER" == ${cfg.user} ]]; then
          exec ${lib.getExe' cfg.package "peertube-runner"} "$@"
        else
          echo "This has to be run with the \`${cfg.user}\` user. Ex: \`sudo -u ${cfg.user} peertube-runner\`"
        fi
      '')
    ];

    services.peertube-runner.settings = {
      transcription = lib.mkIf (lib.elem "video-transcription" cfg.enabledJobTypes) {
        engine = lib.mkDefault "whisper-ctranslate2";
        enginePath = lib.mkDefault (lib.getExe pkgs.whisper-ctranslate2);
      };
    };

    systemd.services.peertube-runner = {
      after = [
        "network.target"
        (lib.mkIf config.services.peertube.enable "peertube.service")
      ];

      description = "peertube-runner daemon";
      environment = env;
      path = [ pkgs.ffmpeg-headless ];

      script = ''
        config_dir=$XDG_CONFIG_HOME/peertube-runner-nodejs/default
        mkdir -p $config_dir
        config_file=$config_dir/config.toml
        cp -f --no-preserve=mode,ownership ${configFile} $config_file

        ${lib.optionalString ((lib.length (lib.attrNames cfg.instancesToRegister)) > 0) ''
          # Temp config directory for registration commands
          temp_dir=$(mktemp --directory)
          temp_config_dir=$temp_dir/peertube-runner-nodejs/default
          mkdir -p $temp_config_dir
          temp_config_file=$temp_config_dir/config.toml

          mkdir -p $STATE_DIRECTORY/runner_tokens
          ${lib.concatMapAttrsStringSep "\n" (instanceName: instance: ''
            runner_token_file=$STATE_DIRECTORY/runner_tokens/${instanceName}

            # Register any currenctly unregistered instances.
            if [ ! -f $runner_token_file ] || [[ $(cat $runner_token_file) != ptrt-* ]]; then
              # Server has to be running for registration.
              XDG_CONFIG_HOME=$temp_dir ${lib.getExe' cfg.package "peertube-runner"} server &

              XDG_CONFIG_HOME=$temp_dir ${lib.getExe' cfg.package "peertube-runner"} register \
                --url ${lib.escapeShellArg instance.url} \
                --registration-token "$(cat ${instance.registrationTokenFile})" \
                --runner-name ${lib.escapeShellArg instance.runnerName} \
                ${lib.optionalString (
                  instance.runnerDescription != null
                ) "--runner-description ${lib.escapeShellArg instance.runnerDescription}"}

              # Kill the server
              kill $!

              ${lib.getExe pkgs.yq-go} -e ".registeredInstances[0].runnerToken" \
                $temp_config_file > $runner_token_file
              rm $temp_config_file
            fi

            echo "

            [[registeredInstances]]
            url = \"${instance.url}\"
            runnerToken = \"$(cat $runner_token_file)\"
            runnerName = \"${instance.runnerName}\"
            ${lib.optionalString (
              instance.runnerDescription != null
            ) ''runnerDescription = \"${instance.runnerDescription}\"''}
            " >> $config_file
          '') cfg.instancesToRegister}
        ''}

        # Don't allow changes that won't persist.
        chmod 440 $config_file

        systemd-notify --ready
        exec ${lib.getExe' cfg.package "peertube-runner"} server ${
          lib.concatMapStringsSep " " (jobType: "--enable-job ${jobType}") cfg.enabledJobTypes
        }
      '';

      serviceConfig = {
        CacheDirectory = "peertube-runner";
        CacheDirectoryMode = "0700";
        CapabilityBoundingSet = "~CAP_SYS_ADMIN";
        Group = cfg.group;
        NoNewPrivileges = true;
        NotifyAccess = "all"; # for systemd-notify
        ProtectHome = true;
        ProtectSystem = "full";
        Restart = "always";
        RestartSec = 5;
        RuntimeDirectory = "peertube-runner";
        RuntimeDirectoryMode = "0700";
        StateDirectory = "peertube-runner";
        StateDirectoryMode = "0700";
        SyslogIdentifier = "prunner";
        Type = "notify";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups = lib.mkIf (cfg.group == "prunner") {
      ${cfg.group} = { };
    };

    users.users = lib.mkIf (cfg.user == "prunner") {
      ${cfg.user} = {
        group = cfg.group;
        isSystemUser = true;
      };
    };

    warnings = lib.optional (cfg.instancesToRegister == { }) ''
      `services.peertube-runner.instancesToRegister` is empty.
      Instances cannot be manually registered using the command line.
    '';
  };

  meta.teams = [ lib.teams.ngi ];
}
