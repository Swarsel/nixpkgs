{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.marytts;
  format = pkgs.formats.javaProperties { };
in
{
  options.services.marytts = {
    enable = lib.mkEnableOption "MaryTTS";
    package = lib.mkPackageOption pkgs "marytts" { };

    basePath = lib.mkOption {
      default = "/var/lib/marytts";

      description = ''
        The base path in which MaryTTS runs.
      '';

      type = lib.types.path;
    };

    openFirewall = lib.mkOption {
      default = false;

      description = ''
        Whether to open the port in the firewall for MaryTTS.
      '';

      example = true;
      type = lib.types.bool;
    };

    port = lib.mkOption {
      default = 59125;

      description = ''
        Port to bind the MaryTTS server to.
      '';

      type = lib.types.port;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Settings for MaryTTS.

        See the [default settings](https://github.com/marytts/marytts/blob/master/marytts-runtime/conf/marybase.config)
        for a list of possible keys.
      '';

      type = lib.types.submodule {
        freeformType = format.type;
      };
    };

    userDictionaries = lib.mkOption {
      default = [ ];

      description = ''
        Paths to the user dictionary files for MaryTTS.
      '';

      example = lib.literalExpression ''
        [
          (pkgs.writeTextFile {
            name = "userdict-en_US";
            destination = "/userdict-en_US.txt";
            text = '''
              Nixpkgs | n I k s - ' p { - k @ - dZ @ s
            ''';
          })
        ]
      '';

      type = lib.types.listOf lib.types.path;
    };

    voices = lib.mkOption {
      default = [ ];

      description = ''
        Paths to the JAR files that contain additional voices for MaryTTS.

        Voices are automatically detected by MaryTTS, so there is no need to alter
        your config to make use of new voices.
      '';

      example = lib.literalExpression ''
        [
          (pkgs.fetchzip {
            url = "https://github.com/marytts/voice-bits1-hsmm/releases/download/v5.2/voice-bits1-hsmm-5.2.zip";
            hash = "sha256-1nK+qZxjumMev7z5lgKr660NCKH5FDwvZ9sw/YYYeaA=";
          })
        ]
      '';

      type = lib.types.listOf lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    services.marytts.settings = {
      "mary.base" = lib.mkDefault cfg.basePath;
      "socket.port" = lib.mkDefault cfg.port;
    };

    systemd.services.marytts = {
      after = [ "network.target" ];
      description = "MaryTTS server instance";
      restartTriggers = cfg.voices ++ cfg.userDictionaries;

      # FIXME: MaryTTS's config loading mechanism appears to be horrendously broken
      # and it doesn't seem to actually read config files outside of precompiled JAR files.
      # Using system properties directly works for now, but this is really ugly.
      script = ''
        ${lib.getExe pkgs.marytts} -classpath "${cfg.basePath}/lib/*:${cfg.package}/lib/*" ${
          lib.concatStringsSep " " (lib.mapAttrsToList (n: v: ''-D${n}="${v}"'') cfg.settings)
        }
      '';

      serviceConfig = {
        AmbientCapabilities = lib.optional (cfg.port < 1024) "CAP_NET_BIND_SERVICE";
        CapabilityBoundingSet = "";
        DynamicUser = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = false; # Java does not like w^x :(
        PrivateDevices = true;
        PrivateNetwork = false;
        PrivateTmp = true;
        PrivateUsers = cfg.port >= 1024;
        ProcSubset = "pid";
        # Hardening
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        Restart = "on-failure";
        RestartSec = 5;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RuntimeDirectory = "marytts";
        StateDirectory = "marytts";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@resources"
          "~@privileged"
        ];

        TimeoutSec = 20;
        UMask = "0027";
        User = "marytts";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.settings."10-marytts" = {
      "${cfg.basePath}/lib"."L+".argument = "${pkgs.symlinkJoin {
        name = "marytts-lib";
        # Put user paths before default ones so that user ones have priority
        paths = cfg.voices ++ [ "${cfg.package}/lib" ];
      }}";

      "${cfg.basePath}/user-dictionaries"."L+".argument = "${pkgs.symlinkJoin {
        name = "marytts-user-dictionaries";
        # Put user paths before default ones so that user ones have priority
        paths = cfg.userDictionaries ++ [ "${cfg.package}/user-dictionaries" ];
      }}";
    };
  };
}
