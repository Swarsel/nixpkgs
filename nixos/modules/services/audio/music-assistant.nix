{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    mkPackageOption
    types
    ;

  inherit (types)
    bool
    listOf
    enum
    str
    ;

  cfg = config.services.music-assistant;

  finalPackage = cfg.package.override {
    inherit (cfg) providers;
  };

  # YouTube Music needs deno with JIT to solve yt-dlp challenges
  useYTMusic = lib.elem "ytmusic" cfg.providers;
in

{
  options.services.music-assistant = {
    enable = mkEnableOption "Music Assistant";
    package = mkPackageOption pkgs "music-assistant" { };

    extraOptions = mkOption {
      default = [
        "--config"
        "/var/lib/music-assistant"
      ];

      description = ''
        List of extra options to pass to the music-assistant executable.
      '';

      example = [
        "--log-level"
        "DEBUG"
      ];

      type = listOf str;
    };

    openFirewall = lib.mkOption {
      default = false;

      description = ''
        Whether to open required ports for the configured providers.
        Currently airplay and sendspin need port to be opened to function.
      '';

      type = bool;
    };

    providers = mkOption {
      default = [ ];

      description = ''
        List of provider names for which dependencies will be installed.
      '';

      example = [
        "opensubsonic"
        "snapcast"
      ];

      type = listOf (enum cfg.package.providerNames);
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts =
        lib.optional cfg.enable 8097 # Music Assistant stream port
        ++ lib.optional (lib.elem "airplay" cfg.providers) 7000
        ++ lib.optional (lib.elem "sendspin" cfg.providers) 8927
        ++ lib.optional (lib.elem "snapcast" cfg.providers) 1780
        ++ lib.optionals (lib.elem "squeezelite" cfg.providers) [
          # https://lyrion.org/reference/slimproto-protocol/
          3483 # Slimproto control
          # https://lyrion.org/reference/cli/using-the-cli/
          9000 # Slimproto JSON-RPC
          9090 # Slimproto CLI
        ];

      # The information published by Apple 1 seem to not apply to libraop.
      # The closest we could find that represents the port range being used as observed by tcpdump is the ephemeral port range.
      # 1: https://support.apple.com/en-us/103229#:~:text=49152%E2%80%93-,65535,-TCP%2C%20UDP
      # 2: https://en.wikipedia.org/wiki/Ephemeral_port#Range
      allowedUDPPortRanges = lib.mkIf (lib.elem "airplay" cfg.providers) [
        {
          from = 32768;
          to = 65535;
        }
      ];

      allowedUDPPorts = lib.optionals (lib.elem "squeezelite" cfg.providers) [
        # https://lyrion.org/reference/slimproto-protocol/
        3483 # Slimproto discovery
      ];
    };

    services = {
      avahi = lib.mkIf (lib.elem "airplay_receiver" cfg.providers) {
        enable = true;
        openFirewall = lib.mkIf cfg.openFirewall true;

        publish = {
          enable = true;
          userServices = true;
        };
      };

      music-assistant.providers = cfg.package.providersBuiltins;
    };

    systemd.services.music-assistant = {
      after = [ "network-online.target" ];
      description = "Music Assistant";
      documentation = [ "https://music-assistant.io" ];

      environment = {
        HOME = "/var/lib/music-assistant";
        PYTHONPATH = finalPackage.pythonPath;
      };

      path =
        with pkgs;
        [
          lsof
        ]
        ++ lib.optionals (lib.elem "airplay" cfg.providers) [
          cliairplay
          libraop
        ]
        ++ lib.optionals (lib.elem "airplay_receiver" cfg.providers) [
          shairport-sync
        ]
        ++ lib.optionals (lib.elem "spotify" cfg.providers) [
          librespot-ma
        ]
        ++ lib.optionals (lib.elem "spotify_connect" cfg.providers) [
          go-librespot
        ]
        ++ lib.optionals (lib.elem "snapcast" cfg.providers) [
          snapcast
        ]
        ++ lib.optionals useYTMusic [
          deno
          ffmpeg-headless
        ];

      serviceConfig = {
        AmbientCapabilities = "";
        # required for torch to properly detect the supported engines
        # allows Music-Assistant to warn, if x86_64-v2 cpu features are missing
        BindReadOnlyPaths = [ "/proc/cpuinfo" ];
        CapabilityBoundingSet = [ "" ];
        DevicePolicy = "closed";
        DynamicUser = true;

        ExecStart = utils.escapeSystemdExecArgs (
          [
            (lib.getExe cfg.package)
          ]
          ++ cfg.extraOptions
        );

        LockPersonality = true;
        # breaks pyopenssl's cffi calls, used in remote access feature
        # not compatible with llvmlite which is required by numba -> librosa
        MemoryDenyWriteExecute = false;
        ProcSubset = "all";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ]
        ++ lib.optionals (lib.elem "snapcast" cfg.providers) [
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "music-assistant";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "mbind"
        ]
        ++ lib.optionals useYTMusic [
          "@pkey"
        ];

        UMask = "0077";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta.buildDocsInSandbox = false;
}
