{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.pulseaudio;

  hasZeroconf =
    let
      z = cfg.zeroconf;
    in
    z.publish.enable || z.discovery.enable;

  overriddenPackage = cfg.package.override (
    lib.optionalAttrs hasZeroconf { zeroconfSupport = true; }
  );
  binary = "${lib.getBin overriddenPackage}/bin/pulseaudio";
  binaryNoDaemon = "${binary} --daemonize=no";

  # Forces 32bit pulseaudio and alsa-plugins to be built/supported for apps
  # using 32bit alsa on 64bit linux.
  enable32BitAlsaPlugins =
    cfg.support32Bit
    && pkgs.stdenv.hostPlatform.isx86_64
    && (pkgs.pkgsi686Linux.alsa-lib != null && pkgs.pkgsi686Linux.libpulseaudio != null);

  myConfigFile =
    let
      addModuleIf = cond: mod: lib.optionalString cond "load-module ${mod}";
      allAnon = lib.optional cfg.tcp.anonymousClients.allowAll "auth-anonymous=1";
      ipAnon =
        let
          a = cfg.tcp.anonymousClients.allowedIpRanges;
        in
        lib.optional (a != [ ]) "auth-ip-acl=${lib.concatStringsSep ";" a}";
      port = lib.optional (!(isNull cfg.tcp.port)) "port=${toString cfg.tcp.port}";
    in
    pkgs.writeTextFile {
      name = "default.pa";

      text = ''
        .include ${cfg.configFile}
        ${addModuleIf cfg.zeroconf.publish.enable "module-zeroconf-publish"}
        ${addModuleIf cfg.zeroconf.discovery.enable "module-zeroconf-discover"}
        ${addModuleIf cfg.tcp.enable (
          lib.concatStringsSep " " ([ "module-native-protocol-tcp" ] ++ allAnon ++ ipAnon ++ port)
        )}
        ${addModuleIf config.services.jack.jackd.enable "module-jack-sink"}
        ${addModuleIf config.services.jack.jackd.enable "module-jack-source"}
        ${cfg.extraConfig}
      '';
    };

  ids = config.ids;

  uid = ids.uids.pulseaudio;
  gid = ids.gids.pulseaudio;

  stateDir = "/run/pulse";

  # Create pulse/client.conf even if PulseAudio is disabled so
  # that we can disable the autospawn feature in programs that
  # are built with PulseAudio support (like KDE).
  clientConf = pkgs.writeText "client.conf" ''
    autospawn=no
    ${cfg.extraClientConf}
  '';

  # Write an /etc/asound.conf that causes all ALSA applications to
  # be re-routed to the PulseAudio server through ALSA's Pulse
  # plugin.
  alsaConf = ''
    pcm_type.pulse {
      libs.native = ${pkgs.alsa-plugins}/lib/alsa-lib/libasound_module_pcm_pulse.so ;
      ${lib.optionalString enable32BitAlsaPlugins "libs.32Bit = ${pkgs.pkgsi686Linux.alsa-plugins}/lib/alsa-lib/libasound_module_pcm_pulse.so ;"}
    }
    pcm.!default {
      type pulse
      hint.description "Default Audio Device (via PulseAudio)"
    }
    ctl_type.pulse {
      libs.native = ${pkgs.alsa-plugins}/lib/alsa-lib/libasound_module_ctl_pulse.so ;
      ${lib.optionalString enable32BitAlsaPlugins "libs.32Bit = ${pkgs.pkgsi686Linux.alsa-plugins}/lib/alsa-lib/libasound_module_ctl_pulse.so ;"}
    }
    ctl.!default {
      type pulse
    }
  '';

in
{
  imports = [
    (lib.mkRenamedOptionModule [ "hardware" "pulseaudio" ] [ "services" "pulseaudio" ])
  ];

  options = {

    services.pulseaudio = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable the PulseAudio sound server.
        '';

        type = lib.types.bool;
      };

      package = lib.mkOption {
        default = if config.services.jack.jackd.enable then pkgs.pulseaudioFull else pkgs.pulseaudio;
        defaultText = lib.literalExpression "pkgs.pulseaudio";

        description = ''
          The PulseAudio derivation to use.  This can be used to enable
          features (such as JACK support, Bluetooth) via the
          `pulseaudioFull` package.
        '';

        example = lib.literalExpression "pkgs.pulseaudioFull";
        type = lib.types.package;
      };

      configFile = lib.mkOption {
        description = ''
          The path to the default configuration options the PulseAudio server
          should use. By default, the "default.pa" configuration
          from the PulseAudio distribution is used.
        '';

        type = lib.types.nullOr lib.types.path;
      };

      daemon = {
        config = lib.mkOption {
          default = { };
          description = "Config of the pulse daemon. See `man pulse-daemon.conf`.";
          example = lib.literalExpression ''{ realtime-scheduling = "yes"; }'';
          type = lib.types.attrsOf lib.types.unspecified;
        };

        logLevel = lib.mkOption {
          default = "notice";

          description = ''
            The log level that the system-wide pulseaudio daemon should use,
            if activated.
          '';

          type = lib.types.str;
        };
      };

      extraClientConf = lib.mkOption {
        default = "";

        description = ''
          Extra configuration appended to pulse/client.conf file.
        '';

        type = lib.types.lines;
      };

      extraConfig = lib.mkOption {
        default = "";

        description = ''
          Literal string to append to `configFile`
          and the config file generated by the pulseaudio module.
        '';

        type = lib.types.lines;
      };

      extraModules = lib.mkOption {
        default = [ ];

        description = ''
          Extra pulseaudio modules to use. This is intended for out-of-tree
          pulseaudio modules like extra bluetooth codecs.

          Extra modules take precedence over built-in pulseaudio modules.
        '';

        example = lib.literalExpression "[ pkgs.pulseaudio-modules-bt ]";
        type = lib.types.listOf lib.types.package;
      };

      support32Bit = lib.mkOption {
        default = false;

        description = ''
          Whether to include the 32-bit pulseaudio libraries in the system or not.
          This is only useful on 64-bit systems and currently limited to x86_64-linux.
        '';

        type = lib.types.bool;
      };

      systemWide = lib.mkOption {
        default = false;

        description = ''
          If false, a PulseAudio server is launched automatically for
          each user that tries to use the sound system. The server runs
          with user privileges. If true, one system-wide PulseAudio
          server is launched on boot, running as the user "pulse", and
          only users in the "pulse-access" group will have access to the server.
          Please read the PulseAudio documentation for more details.

          Don't enable this option unless you know what you are doing.
        '';

        type = lib.types.bool;
      };

      # TODO: enable by default?
      tcp = {
        enable = lib.mkEnableOption "tcp streaming support";

        anonymousClients = {
          allowAll = lib.mkEnableOption "all anonymous clients to stream to the server";

          allowedIpRanges = lib.mkOption {
            default = [ ];

            description = ''
              A list of IP subnets that are allowed to stream to the server.
            '';

            example = lib.literalExpression ''[ "127.0.0.1" "192.168.1.0/24" ]'';
            type = lib.types.listOf lib.types.str;
          };
        };

        openFirewall = lib.mkEnableOption "Open firewall for the specified port";

        port = lib.mkOption {
          default = null;

          description = ''
            TCP connection port. The default `null` value, means
            pulseaudio will try to use the default 4713 port, but if it is
            occupied, it will fallback to a random port.
          '';

          # Per https://www.freedesktop.org/wiki/Software/PulseAudio/Documentation/User/Network/#directconnection
          example = 4713;
          type = lib.types.nullOr lib.types.port;
        };
      };

      zeroconf = {
        discovery.enable = lib.mkEnableOption "discovery of pulseaudio sinks in the local network";
        publish.enable = lib.mkEnableOption "publishing the pulseaudio sink in the local network";
      };

    };

  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = cfg.tcp.openFirewall -> (!isNull cfg.tcp.port);
            message = "If you wish to open the firewall for the Pulseaudio's tcp.port, set the port explicitly";
          }
        ];

        environment.etc = {
          "alsa/conf.d/99-pulseaudio.conf".text = alsaConf;
          "libao.conf".source = pkgs.writeText "libao.conf" "default_driver=pulse";
          "openal/alsoft.conf".source = pkgs.writeText "alsoft.conf" "drivers=pulse";

          "pulse/daemon.conf".source = pkgs.writeText "daemon.conf" (
            lib.generators.toKeyValue { } cfg.daemon.config
          );
        };

        environment.etc."pulse/client.conf".source = clientConf;
        environment.systemPackages = [ overriddenPackage ];
        # Allow PulseAudio to get realtime priority using rtkit.
        security.rtkit.enable = true;
        services.pulseaudio.configFile = lib.mkDefault "${lib.getBin overriddenPackage}/etc/pulse/default.pa";
        # Disable flat volumes to enable relative ones
        services.pulseaudio.daemon.config.flat-volumes = lib.mkDefault "no";
        # Upstream defaults to speex-float-1 which results in audible artifacts
        services.pulseaudio.daemon.config.resample-method = lib.mkDefault "speex-float-5";
        # PulseAudio is packaged with udev rules to handle various audio device quirks
        services.udev.packages = [ overriddenPackage ];
        systemd.packages = [ overriddenPackage ];
      }

      (lib.mkIf (cfg.extraModules != [ ]) {
        services.pulseaudio.daemon.config.dl-search-path =
          let
            overriddenModules = map (drv: drv.override { pulseaudio = overriddenPackage; }) cfg.extraModules;
            modulePaths =
              map (drv: "${drv}/lib/pulseaudio/modules")
                # User-provided extra modules take precedence
                (overriddenModules ++ [ overriddenPackage ]);
          in
          lib.concatStringsSep ":" modulePaths;
      })

      (lib.mkIf hasZeroconf {
        services.avahi.enable = true;
      })
      (lib.mkIf cfg.zeroconf.publish.enable {
        services.avahi.publish.enable = true;
        services.avahi.publish.userServices = true;
      })
      (lib.mkIf cfg.tcp.openFirewall {
        networking.firewall.allowedTCPPorts = [ cfg.tcp.port ];
      })

      (lib.mkIf (!cfg.systemWide) {
        environment.etc = {
          "pulse/default.pa".source = myConfigFile;
        };

        systemd.user = {
          services.pulseaudio = {
            restartIfChanged = true;

            serviceConfig = {
              PassEnvironment = "DISPLAY";
              RestartSec = "500ms";
            };
          }
          // lib.optionalAttrs config.services.jack.jackd.enable {
            environment.JACK_PROMISCUOUS_SERVER = "jackaudio";
          };

          sockets.pulseaudio = {
            wantedBy = [ "sockets.target" ];
          };
        };
      })

      (lib.mkIf cfg.systemWide {
        environment.variables.PULSE_COOKIE = "${stateDir}/.config/pulse/cookie";

        systemd.services.pulseaudio = {
          before = [ "sound.target" ];
          description = "PulseAudio System-Wide Server";
          environment.PULSE_RUNTIME_PATH = stateDir;

          serviceConfig = {
            ExecStart = "${binaryNoDaemon} --log-level=${cfg.daemon.logLevel} --system -n --file=${myConfigFile}";
            Restart = "on-failure";
            RestartSec = "500ms";
            Type = "notify";
          };

          wantedBy = [ "sound.target" ];
        };

        users.groups.pulse.gid = gid;
        users.groups.pulse-access = { };

        users.users.pulse = {
          createHome = true;
          description = "PulseAudio system service user";
          extraGroups = [ "audio" ];
          group = "pulse";
          home = stateDir;
          homeMode = "755";
          isSystemUser = true;

          # For some reason, PulseAudio wants UID == GID.
          uid =
            assert uid == gid;
            uid;
        };
      })
    ]
  );

}
